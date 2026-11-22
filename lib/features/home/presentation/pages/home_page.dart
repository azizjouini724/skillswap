import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/matching/presentation/widgets/smart_match_banner.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/notifications/presentation/widgets/notification_bell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillSwap'),
        actions: const [NotificationBell(), SizedBox(width: 4)],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (_, state) => state is! ProfileActionFailed,
        builder: (context, state) {
          if (state is! ProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = state.profile;
          final muted = Theme.of(context).colorScheme.onSurfaceVariant;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        photoUrl: profile.photoUrl,
                        initials: profile.initials,
                        radius: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back',
                                style: TextStyle(color: muted, fontSize: 13)),
                            Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SmartMatchBanner(
                    onTap: () => context.go(AppRoutes.matches),
                  ),
                  if (profile.completedSteps < ProfileEntity.totalSteps) ...[
                    const SizedBox(height: 16),
                    _CompleteProfileCard(profile: profile),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompleteProfileCard extends StatelessWidget {
  final ProfileEntity profile;
  const _CompleteProfileCard({required this.profile});

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
                Icon(Icons.swap_horizontal_circle_outlined,
                    color: scheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Get swap-ready',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '${profile.completedSteps}/${ProfileEntity.totalSteps}',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: profile.completion,
                minHeight: 8,
                backgroundColor: scheme.primary.withValues(alpha: 0.14),
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.profile),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: const StadiumBorder(),
              ),
              child: const Text('Complete my profile'),
            ),
          ],
        ),
      ),
    );
  }
}