import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:skillswap/features/discover/presentation/widgets/discover_profile_card.dart';
import 'package:skillswap/features/skills/domain/entities/skill_catalog.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_icons.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final uid = context.read<AuthBloc>().currentUser?.uid;
    if (uid == null) return Future.value();
    final done = Completer<void>();
    context.read<DiscoverBloc>().add(DiscoverRequested(uid, done: done));
    return done.future;
  }

  void _clearFilters() {
    _searchController.clear();
    final bloc = context.read<DiscoverBloc>();
    bloc.add(const DiscoverQueryChanged(''));
    bloc.add(const DiscoverCategoryChanged(null));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, [double width = 1.2]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<DiscoverBloc, DiscoverState>(
            builder: (context, state) {
              final loaded = state is DiscoverLoaded ? state : null;
              final bloc = context.read<DiscoverBloc>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text(
                      'Discover',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => bloc.add(DiscoverQueryChanged(v)),
                      decoration: InputDecoration(
                        hintText: 'Search a skill or a name',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: (loaded?.query.isNotEmpty ?? false)
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  bloc.add(const DiscoverQueryChanged(''));
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        border: border(scheme.outlineVariant),
                        enabledBorder: border(scheme.outlineVariant),
                        focusedBorder: border(scheme.primary, 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _CategoryChip(
                          label: 'All',
                          icon: Icons.apps_rounded,
                          selected: loaded?.categoryId == null,
                          onTap: () =>
                              bloc.add(const DiscoverCategoryChanged(null)),
                        ),
                        for (final c in SkillCatalog.categories)
                          _CategoryChip(
                            label: c.label,
                            icon: SkillIcons.forCategory(c.id),
                            selected: loaded?.categoryId == c.id,
                            onTap: () => bloc.add(DiscoverCategoryChanged(
                              loaded?.categoryId == c.id ? null : c.id,
                            )),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _Body(
                      state: state,
                      onRefresh: _refresh,
                      onClear: _clearFilters,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: selected,
        selectedColor: primary.withValues(alpha: 0.18),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final DiscoverState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onClear;

  const _Body({
    required this.state,
    required this.onRefresh,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final s = state;

    if (s is DiscoverLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s is DiscoverFailure) {
      return _Message(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        subtitle: s.message,
        actionLabel: 'Try again',
        onAction: () => onRefresh(),
      );
    }
    if (s is DiscoverLoaded) {
      if (s.all.isEmpty) {
        return _Message(
          icon: Icons.group_outlined,
          title: 'No one here yet',
          subtitle: 'Invite friends to join SkillSwap and start swapping skills.',
          actionLabel: 'Refresh',
          onAction: () => onRefresh(),
        );
      }
      if (s.visible.isEmpty) {
        return _Message(
          icon: Icons.search_off_rounded,
          title: 'No result',
          subtitle: 'Try another skill or clear the filters.',
          actionLabel: 'Clear filters',
          onAction: onClear,
        );
      }
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: s.visible.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final profile = s.visible[index];
            return DiscoverProfileCard(
              profile: profile,
              onTap: () => context.push(AppRoutes.userProfile(profile.uid)),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
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