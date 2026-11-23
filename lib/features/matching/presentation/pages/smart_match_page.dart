import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/matching/presentation/bloc/match_bloc.dart';
import 'package:skillswap/features/matching/presentation/widgets/match_card.dart';
import 'package:skillswap/features/profile/domain/entities/profile_entity.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/foundation.dart';
class SmartMatchPage extends StatelessWidget {
  const SmartMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Match')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (_, state) => state is! ProfileActionFailed,
        builder: (context, state) {
          if (state is ProfileLoaded) return _MatchView(profile: state.profile);
          if (state is ProfileFailure) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _MatchView extends StatefulWidget {
  final ProfileEntity profile;
  const _MatchView({required this.profile});

  @override
  State<_MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<_MatchView> {
  /// Il faut au moins une compétence de chaque côté pour matcher.
  bool get _ready =>
      widget.profile.skillsToTeach.isNotEmpty &&
      widget.profile.skillsToLearn.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_ready) _load();
  }

  @override
  void didUpdateWidget(covariant _MatchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = !listEquals(
        oldWidget.profile.skillsToTeach, widget.profile.skillsToTeach) ||
      !listEquals(
        oldWidget.profile.skillsToLearn, widget.profile.skillsToLearn);
    if (changed && _ready) _load();
  }

  Future<void> _load() {
    final done = Completer<void>();
    context.read<MatchBloc>().add(MatchRequested(widget.profile, done: done));
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return _Message(
        icon: Icons.tune_rounded,
        title: 'Complete your skills first',
        subtitle:
            'Add at least one skill you can teach and one you want to learn to find matches.',
        actionLabel: 'Go to profile',
        onAction: () => context.go(AppRoutes.profile),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchFailure) {
              return _Message(
                icon: Icons.cloud_off_rounded,
                title: 'Something went wrong',
                subtitle: state.message,
                actionLabel: 'Try again',
                onAction: _load,
              );
            }
            if (state is! MatchLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.matches.isEmpty) {
              return _Message(
                icon: Icons.search_off_rounded,
                title: 'No perfect match yet',
                subtitle:
                    'A match needs someone who teaches what you want to learn AND wants to learn what you teach. Add more skills or check back later.',
                actionLabel: 'Refresh',
                onAction: _load,
              );
            }

            final muted = Theme.of(context).colorScheme.onSurfaceVariant;
            final count = state.matches.length;

            return RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: count + 1,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count perfect match${count == 1 ? '' : 'es'}',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'They teach what you want to learn, and want to learn what you teach.',
                          style: TextStyle(color: muted, height: 1.4),
                        ),
                      ],
                    );
                  }
                  final match = state.matches[index - 1];
                  return MatchCard(
                    match: match,
                    onTap: () =>
                        context.push(AppRoutes.userProfile(match.profile.uid)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _Message({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 46),
                shape: const StadiumBorder(),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}