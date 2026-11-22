import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/auth/presentation/widgets/swap_animation.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9E5FB), AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white, size: 46),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SkillSwap',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Learn • Teach • Exchange',
                  style: TextStyle(color: AppColors.textLight, fontSize: 15),
                ),
                const Spacer(),
                const SwapAnimation(),
                const Spacer(),
                const Text(
                  'Exchange skills.\nUnlock new opportunities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text('Get Started'),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}