import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillswap/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/skills/presentation/widgets/skills_card.dart';

class PublicProfilePage extends StatelessWidget {
  final String uid;
  const PublicProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<DiscoverBloc, DiscoverState>(
        builder: (context, state) {
          if (state is DiscoverLoaded) {
            final matches = state.all.where((p) => p.uid == uid);
            if (matches.isEmpty) {
              return const Center(child: Text('Profile not found'));
            }
            return _Content(profile: matches.first);
          }
          if (state is DiscoverFailure) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ProfileEntity profile;
  const _Content({required this.profile});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        photoUrl: profile.photoUrl,
                        initials: profile.initials,
                        radius: 52,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      if (profile.city.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 15, color: muted),
                            const SizedBox(width: 4),
                            Text(profile.city,
                                style: TextStyle(color: muted, fontSize: 13)),
                          ],
                        ),
                      ],
                      if (profile.hasBio) ...[
                        const SizedBox(height: 12),
                        Text(
                          profile.bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SkillsCard(
                title: 'Teaches',
                icon: Icons.school_outlined,
                skills: profile.skillsToTeach,
                filled: true,
              ),
              const SizedBox(height: 16),
              SkillsCard(
                title: 'Wants to learn',
                icon: Icons.auto_stories_outlined,
                skills: profile.skillsToLearn,
                filled: false,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exchange requests arrive in the next step'),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Request an exchange'),
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}