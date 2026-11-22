import 'package:flutter/material.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_entity.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/status_chip.dart';
import 'package:skillswap/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:skillswap/features/skills/presentation/widgets/skill_chip.dart';

class ExchangeCard extends StatelessWidget {
  final ExchangeEntity exchange;
  final String uid;
  final void Function(String status) onStatus;
  final VoidCallback onPlanSession;

  const ExchangeCard({
    super.key,
    required this.exchange,
    required this.uid,
    required this.onStatus,
    required this.onPlanSession,
  });

  static final _compact = ElevatedButton.styleFrom(
    minimumSize: const Size(0, 44),
    shape: const StadiumBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = exchange;
    final sent = e.isSender(uid);
    final name = e.otherName(uid);
    final actions = _actions(context);

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
                    photoUrl: null, initials: initialsOf(name), radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${sent ? 'Sent' : 'Received'} ${DateFmt.date(e.createdAt)}',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: e.status),
              ],
            ),
            const SizedBox(height: 14),
            _Line(
              icon: Icons.school_outlined,
              label: 'You teach',
              skill: e.teachOf(uid),
              filled: true,
            ),
            const SizedBox(height: 8),
            _Line(
              icon: Icons.auto_stories_outlined,
              label: 'You learn',
              skill: e.learnOf(uid),
              filled: false,
            ),
            if (e.message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  e.message,
                  style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.4),
                ),
              ),
            ],
            if (actions != null) ...[
              const SizedBox(height: 14),
              actions,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _actions(BuildContext context) {
    final e = exchange;

    if (e.isPending && e.receiverId == uid) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatus(ExchangeStatus.rejected),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                shape: const StadiumBorder(),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onStatus(ExchangeStatus.accepted),
              style: _compact,
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    }

    if (e.isPending) {
      return OutlinedButton(
        onPressed: () => onStatus(ExchangeStatus.cancelled),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          shape: const StadiumBorder(),
        ),
        child: const Text('Cancel request'),
      );
    }

    if (e.isAccepted) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: onPlanSession,
            icon: const Icon(Icons.event_rounded, size: 18),
            label: const Text('Plan a session'),
            style: _compact.copyWith(
              minimumSize:
                  const WidgetStatePropertyAll(Size.fromHeight(44)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => onStatus(ExchangeStatus.completed),
                  child: const Text('Mark completed'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => onStatus(ExchangeStatus.cancelled),
                  child: const Text('Cancel exchange'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return null;
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String label;
  final String skill;
  final bool filled;

  const _Line({
    required this.icon,
    required this.label,
    required this.skill,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: muted),
          ),
        ),
        SkillChip(label: skill, filled: filled),
      ],
    );
  }
}