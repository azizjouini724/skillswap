import 'package:flutter/material.dart';
import 'package:skillswap/features/matching/domain/entities/match_entity.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = match.profile;
    final first = profile.name.trim().split(RegExp(r'\s+')).first;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  photoUrl: profile.photoUrl,
                  initials: profile.initials,
                  radius: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      if (profile.city.isNotEmpty)
                        Text(
                          profile.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: scheme.onSurfaceVariant, fontSize: 13),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded,
                                size: 14, color: scheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Perfect match',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Part(
              icon: Icons.auto_stories_outlined,
              label: '$first teaches you',
              skills: match.youLearn,
              filled: false,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_vert_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),
            _Part(
              icon: Icons.school_outlined,
              label: 'You teach $first',
              skills: match.youTeach,
              filled: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
              child: const Text('View profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Part extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> skills;
  final bool filled;

  const _Part({
    required this.icon,
    required this.label,
    required this.skills,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in skills) SkillChip(label: s, filled: filled),
          ],
        ),
      ],
    );
  }
}