import 'package:flutter/material.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';

class SkillsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> skills;
  final bool filled;
  final String emptyText;

  const SkillsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.skills,
    required this.filled,
    this.emptyText = 'Nothing yet',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    Text(
                      '${skills.length} skill${skills.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (skills.isEmpty)
              Text(emptyText, style: TextStyle(color: scheme.onSurfaceVariant))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in skills) SkillChip(label: s, filled: filled),
                ],
              ),
          ],
        ),
      ),
    );
  }
}