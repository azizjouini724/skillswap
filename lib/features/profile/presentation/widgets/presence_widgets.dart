import 'package:flutter/material.dart';
import 'package:skillswap/core/theme/app_colors.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';

/// Avatar avec un point vert si la personne est en ligne.
class AvatarWithStatus extends StatelessWidget {
  final ProfileEntity profile;
  final double radius;

  const AvatarWithStatus({
    super.key,
    required this.profile,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final dot = radius * 0.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileAvatar(
          photoUrl: profile.photoUrl,
          initials: profile.initials,
          radius: radius,
        ),
        if (profile.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// "Online" en vert, ou "Last seen ..." en gris.
class LastSeenText extends StatelessWidget {
  final ProfileEntity profile;
  const LastSeenText({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final label = DateFmt.lastSeen(profile.lastSeen);
    if (label == null) return const SizedBox.shrink();

    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: profile.isOnline
            ? AppColors.success
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}