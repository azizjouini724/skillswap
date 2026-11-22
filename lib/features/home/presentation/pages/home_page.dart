import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final name = state is ProfileLoaded
            ? state.profile.name
            : (context.read<AuthBloc>().currentUser?.name ?? '');
        return Scaffold(
          appBar: AppBar(title: const Text('SkillSwap')),
          body: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello $name',
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