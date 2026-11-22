import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = context.read<AuthBloc>().currentUser;
        return Scaffold(
          appBar: AppBar(
            title: const Text('SkillSwap'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Se déconnecter',
                onPressed: () =>
                    context.read<AuthBloc>().add(const SignOutRequested()),
              ),
            ],
          ),
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello ${user?.name ?? ''}',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.waving_hand_rounded,
                    size: 28, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}