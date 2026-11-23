import 'package:flutter/material.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';
import 'package:skillswap/features/profile/presentation/widgets/presence_widgets.dart';
class DiscoverProfileCard extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onTap;

  const DiscoverProfileCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWithStatus(profile: profile, radius: 28),
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
                        LastSeenText(profile: profile),
                        if (profile.city.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 14, color: muted),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    profile.city,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: muted, fontSize: 13),
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
              const SizedBox(height: 14),
              _SkillsRow(
                label: 'Teaches',
                icon: Icons.school_outlined,
                skills: profile.skillsToTeach,
                filled: true,
              ),
              const SizedBox(height: 10),
              _SkillsRow(
                label: 'Wants to learn',
                icon: Icons.auto_stories_outlined,
                skills: profile.skillsToLearn,
                filled: false,
              ),
              const SizedBox(height: 14),
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
      ),
    );
  }
}

class _SkillsRow extends StatelessWidget {
  static const maxShown = 3;

  final String label;
  final IconData icon;
  final List<String> skills;
  final bool filled;

  const _SkillsRow({
    required this.label,
    required this.icon,
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
            Icon(icon, size: 15, color: muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: muted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (skills.isEmpty)
          Text('Nothing yet', style: TextStyle(color: muted, fontSize: 13))
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in skills.take(maxShown))
                SkillChip(label: s, filled: filled),
              if (skills.length > maxShown)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+${skills.length - maxShown}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: muted),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}