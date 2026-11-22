import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_icons.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool filled;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const SkillChip({
    super.key,
    required this.label,
    this.filled = false,
    this.icon,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = filled ? Colors.white : scheme.primary;
    final bg = filled ? AppColors.primary : scheme.surface;
    final border =filled ? AppColors.primary : scheme.primary.withValues(alpha: 0.35);
    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, onDeleted == null ? 14 : 6, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ??
                    SkillIcons.forCategory(SkillCatalog.categoryOf(label)),
                size: 16,
                color: fg,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (onDeleted != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onDeleted,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: fg.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}