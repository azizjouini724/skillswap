import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';

class SwapAnimation extends StatefulWidget {
  const SwapAnimation({super.key});

  @override
  State<SwapAnimation> createState() => _SwapAnimationState();
}

class _SwapAnimationState extends State<SwapAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final CurvedAnimation _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final t = _curve.value;
        return SizedBox(
          height: 150,
          width: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: Alignment(-0.8 + 1.6 * t, -0.7),
                child: const _SkillChip('Flutter', Icons.code),
              ),
              Align(
                alignment: Alignment(0.8 - 1.6 * t, 0.7),
                child: const _SkillChip('Photoshop', Icons.brush),
              ),
              Center(
                child: Transform.rotate(
                  angle: t * math.pi,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SkillChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ],
      ),
    );
  }
}