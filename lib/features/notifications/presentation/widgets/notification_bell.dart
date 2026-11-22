import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/features/notifications/presentation/bloc/notification_bloc.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationLoaded ? state.unreadCount : 0;
        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(AppRoutes.notifications),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 9 ? '9+' : '$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}