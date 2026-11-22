import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:skillswap/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:skillswap/features/exchanges/presentation/bloc/exchange_bloc.dart';
import 'package:skillswap/features/matching/presentation/bloc/match_bloc.dart';
import 'package:skillswap/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:skillswap/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:skillswap/injection_container.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProfileBloc>()..add(ProfileStarted(uid)),
        ),
        BlocProvider(
          create: (_) => sl<DiscoverBloc>()..add(DiscoverRequested(uid)),
        ),
        BlocProvider(create: (_) => sl<MatchBloc>()),
        BlocProvider(
          create: (_) => sl<ExchangeBloc>()..add(ExchangesStarted(uid)),
        ),
        BlocProvider(
          create: (_) =>
              sl<NotificationBloc>()..add(NotificationsStarted(uid)),
        ),
        BlocProvider(
          create: (_) => sl<ChatListBloc>()..add(ChatListStarted(uid)),
        ),
      ],
      // Un seul écouteur pour les messages d'actions des échanges.
      child: BlocListener<ExchangeBloc, ExchangeState>(
        listenWhen: (_, state) => state is ExchangeNotice,
        listener: (context, state) {
          if (state is ExchangeNotice) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor:
                  state.isError ? Theme.of(context).colorScheme.error : null,
            ));
          }
        },
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: BlocBuilder<ExchangeBloc, ExchangeState>(
            buildWhen: (_, state) => state is! ExchangeNotice,
            builder: (context, exchangeState) {
              final pending = exchangeState is ExchangeLoaded
                  ? exchangeState.pendingReceived(uid)
                  : 0;

              return BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, chatState) {
                  final unread = chatState is ChatListLoaded
                      ? chatState.unreadCount(uid)
                      : 0;

                  return NavigationBar(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: (index) => navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                    destinations: [
                      const NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home_rounded),
                        label: 'Home',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore_rounded),
                        label: 'Discover',
                      ),
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text('$unread'),
                          child: const Icon(Icons.chat_bubble_outline_rounded),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text('$unread'),
                          child: const Icon(Icons.chat_bubble_rounded),
                        ),
                        label: 'Messages',
                      ),
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: pending > 0,
                          label: Text('$pending'),
                          child: const Icon(Icons.swap_horiz_rounded),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: pending > 0,
                          label: Text('$pending'),
                          child: const Icon(
                              Icons.swap_horizontal_circle_rounded),
                        ),
                        label: 'Exchanges',
                      ),
                      const NavigationDestination(
                        icon: Icon(Icons.person_outline_rounded),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: 'Profile',
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}