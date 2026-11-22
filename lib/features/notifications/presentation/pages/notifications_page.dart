import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/notifications/domain/entities/notification_entity.dart';
import 'package:skillswap/features/notifications/presentation/bloc/notification_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationLoaded || state.unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () => context
                    .read<NotificationBloc>()
                    .add(NotificationsMarkedRead(state.unreadIds)),
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationFailure) {
            return Center(child: Text(state.message));
          }
          if (state is! NotificationLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.items.isEmpty) return const _Empty();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _NotificationTile(
                  item: state.items[i],
                  onTap: () {
                    final n = state.items[i];
                    if (!n.isRead) {
                      context
                          .read<NotificationBloc>()
                          .add(NotificationsMarkedRead([n.id]));
                    }
                    context.go(AppRoutes.exchanges);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  IconData get _icon => switch (item.type) {
        NotificationType.request => Icons.swap_horiz_rounded,
        NotificationType.session => Icons.event_rounded,
        _ => Icons.check_circle_outline_rounded,
      };

  static String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: item.isRead ? null : scheme.primary.withValues(alpha: 0.06),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            item.isRead ? FontWeight.w600 : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(item.createdAt),
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 6, left: 8),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 40, color: scheme.primary),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Requests and session updates will show up here.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}