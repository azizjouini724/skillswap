import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/auth/presentation/widgets/swap_animation.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final bg = theme.scaffoldBackgroundColor;
    final top = Color.alphaBlend(
      scheme.primary.withValues(alpha: dark ? 0.22 : 0.12),
      bg,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [top, bg],
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
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn • Teach • Exchange',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
                ),
                const Spacer(),
                const SwapAnimation(),
                const Spacer(),
                const Text(
                  'Exchange skills.\nUnlock new opportunities.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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