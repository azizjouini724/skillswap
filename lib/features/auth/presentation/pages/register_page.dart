import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/core/utils/validators.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(SignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return AuthBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 170),
                            const Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AuthSwitchLine(
                              question: 'Already have an account?',
                              action: 'sign in',
                              onTap: () => context.go(AppRoutes.login),
                            ),
                            const SizedBox(height: 36),
                            AuthTextField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline_rounded,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) =>
                                  Validators.required(v, 'Le nom'),
                            ),
                            const SizedBox(height: 18),
                            AuthTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 18),
                            AuthTextField(
                              controller: _passwordController,
                              label: 'Password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 40),
                            AuthPillButton(
                              label: 'Sign up',
                              icon: Icons.person_add_alt_1_rounded,
                              loading: loading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 56),
                            const SocialButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.text),
                      onPressed: () => context.go(AppRoutes.welcome),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}