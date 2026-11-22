import 'package:flutter/material.dart';
import 'package:skillswap/core/utils/format_utils.dart';
import 'package:skillswap/features/exchanges/domain/entities/exchange_status.dart';
import 'package:skillswap/features/exchanges/domain/entities/session_entity.dart';
import 'package:skillswap/features/exchanges/presentation/widgets/status_chip.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final String uid;
  final String title;
  final String subtitle;
  final void Function(String status) onStatus;
  final VoidCallback onCounter;

  const SessionCard({
    super.key,
    required this.session,
    required this.uid,
    required this.title,
    required this.subtitle,
    required this.onStatus,
    required this.onCounter,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = session;
    final online = s.meetingMode == MeetingMode.online;
    final waiting = s.status == SessionStatus.proposed && s.hostId == uid;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.event_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: s.status),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Info(
                    icon: Icons.calendar_today_outlined,
                    text: DateFmt.dateTime(s.startAt)),
                _Info(
                    icon: Icons.timer_outlined,
                    text: '${s.durationMinutes} min'),
                _Info(
                  icon: online
                      ? Icons.videocam_outlined
                      : Icons.place_outlined,
                  text: online ? 'Online' : 'In person',
                ),
              ],
            ),
            if (waiting) ...[
              const SizedBox(height: 10),
              Text(
                'Waiting for confirmation',
                style:
                    TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ],
            ..._actions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions() {
    final s = session;
    final style = ElevatedButton.styleFrom(
      minimumSize: const Size(0, 44),
      shape: const StadiumBorder(),
    );

      if (s.canChangeTo(uid, SessionStatus.confirmed)) {
      return [
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => onStatus(SessionStatus.cancelled),
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
                onPressed: () => onStatus(SessionStatus.confirmed),
                style: style,
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton.icon(
            onPressed: onCounter,
            icon: const Icon(Icons.event_repeat_rounded, size: 18),
            label: const Text('Suggest another time'),
          ),
        ),
      ];
    }
    if (s.status == SessionStatus.proposed) {
      return [
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => onStatus(SessionStatus.cancelled),
          child: const Text('Cancel session'),
        ),
      ];
    }
    if (s.status == SessionStatus.confirmed) {
      return [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => onStatus(SessionStatus.completed),
                child: const Text('Mark as done'),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => onStatus(SessionStatus.cancelled),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ];
    }
    return const [];
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: muted)),
      ],
    );
  }
}