import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/core/utils/validators.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _forgotPassword() {
    if (Validators.email(_emailController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saisis d'abord ton email")),
      );
      return;
    }
    context
        .read<AuthBloc>()
        .add(PasswordResetRequested(_emailController.text.trim()));
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
          } else if (state is PasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Email de réinitialisation envoyé'),
            ));
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
                              'Login',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AuthSwitchLine(
                              question: "Don't have an account?",
                              action: 'sign up',
                              onTap: () => context.go(AppRoutes.register),
                            ),
                            const SizedBox(height: 36),
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
                              trailing: TextButton(
                                onPressed: loading ? null : _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'FORGOT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            AuthPillButton(
                              label: 'Login',
                              icon: Icons.login_rounded,
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