import 'package:flutter/material.dart';
import 'package:skillswap/features/stats/domain/entities/user_stats.dart';
import 'package:skillswap/features/stats/domain/usecases/stats_calculator.dart';

class StatsCard extends StatelessWidget {
  final UserStats stats;
  const StatsCard({super.key, required this.stats});

  static String _hours(UserStats s) =>
      s.hours.toStringAsFixed(s.minutes % 60 == 0 ? 0 : 1);

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
                Icon(Icons.insights_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Your stats',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(
                  icon: Icons.event_available_rounded,
                  value: '${stats.sessionsDone}',
                  label: 'Sessions',
                ),
                _Stat(
                  icon: Icons.schedule_rounded,
                  value: _hours(stats),
                  label: 'Hours',
                ),
                _Stat(
                  icon: Icons.groups_rounded,
                  value: '${stats.partners}',
                  label: 'Partners',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'BADGES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in AppBadge.values)
                  _BadgeChip(badge: badge, earned: stats.has(badge)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final AppBadge badge;
  final bool earned;

  const _BadgeChip({required this.badge, required this.earned});

  (IconData, String, String) get _info => switch (badge) {
        AppBadge.swapReady => (
            Icons.verified_rounded,
            'Swap-ready',
            'Complete your profile',
          ),
        AppBadge.firstSwap => (
            Icons.rocket_launch_rounded,
            'First Swap',
            'Complete your first session',
          ),
        AppBadge.topLearner => (
            Icons.workspace_premium_rounded,
            'Top Learner',
            'Complete ${StatsCalculator.topLearnerSessions} sessions',
          ),
        AppBadge.connector => (
            Icons.hub_rounded,
            'Connector',
            'Swap with ${StatsCalculator.connectorPartners} different people',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, title, hint) = _info;
    final color = earned ? scheme.primary : scheme.onSurfaceVariant;

    return Tooltip(
      message: earned ? title : hint,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        decoration: BoxDecoration(
          color: earned
              ? scheme.primary.withValues(alpha: 0.14)
              : scheme.onSurfaceVariant.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(earned ? icon : Icons.lock_outline_rounded,
                size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}