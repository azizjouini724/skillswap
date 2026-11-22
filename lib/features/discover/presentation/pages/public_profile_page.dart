import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/presentation/bloc/exchange_bloc.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/request_exchange_sheet.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
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

  Future<void> _request(BuildContext context) async {
    final me = context.read<ProfileBloc>().profile;
    if (me == null) return;

    final draft = await showModalBottomSheet<RequestDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RequestExchangeSheet(me: me, other: profile),
    );
    if (draft != null && context.mounted) {
      context.read<ExchangeBloc>().add(ExchangeRequested(
            me: me,
            other: profile,
            offeredSkill: draft.offered,
            requestedSkill: draft.requested,
            message: draft.message,
          ));
    }
  }

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
              BlocBuilder<ExchangeBloc, ExchangeState>(
                buildWhen: (_, state) => state is! ExchangeNotice,
                builder: (context, state) {
                  final Iterable<ExchangeEntity> active = state is ExchangeLoaded
                      ? state.exchanges.where((e) =>
                          e.involves(profile.uid) &&
                          (e.isPending || e.isAccepted))
                      : const <ExchangeEntity>[];
                  final pending = active.any((e) => e.isPending);
                  final accepted = active.any((e) => e.isAccepted);

                  if (pending) {
                    return ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.hourglass_top_rounded),
                      label: const Text('Request pending'),
                      style:
                          ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    );
                  }
                  if (accepted) {
                    return ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.exchanges),
                      icon: const Icon(Icons.swap_horizontal_circle_rounded),
                      label: const Text('View exchange'),
                      style:
                          ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    );
                  }
                  return ElevatedButton.icon(
                    onPressed: () => _request(context),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Request an exchange'),
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () =>
                    context.go(AppRoutes.chat(profile.uid, profile.name)),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}