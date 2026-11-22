import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/routes/go_router_refresh_stream.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/pages/register_page.dart';
import 'package:skillswap/features/auth/presentation/pages/welcome_page.dart';
import 'package:skillswap/features/discover/presentation/pages/discover_page.dart';
import 'package:skillswap/features/discover/presentation/pages/public_profile_page.dart';
import 'package:skillswap/features/home/presentation/pages/home_page.dart';
import 'package:skillswap/features/home/presentation/pages/main_shell.dart';
import 'package:skillswap/features/exchanges/presentation/pages/exchanges_page.dart';
import 'package:skillswap/features/profile/presentation/pages/profile_page.dart';
import 'package:skillswap/features/matching/presentation/pages/smart_match_page.dart';
import 'package:skillswap/features/notifications/presentation/pages/notifications_page.dart';
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (!authBloc.initialized) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final loggedIn = authBloc.currentUser != null;
      final onAuthPages = location == AppRoutes.welcome ||
          location == AppRoutes.login ||
          location == AppRoutes.register;

      if (location == AppRoutes.splash) {
        return loggedIn ? AppRoutes.home : AppRoutes.welcome;
      }
      if (!loggedIn && !onAuthPages) return AppRoutes.welcome;
      if (loggedIn && onAuthPages) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
             GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsPage(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.discover,
              builder: (context, state) => const DiscoverPage(),
                            routes: [
                GoRoute(
                  path: 'matches',
                  builder: (context, state) => const SmartMatchPage(),
                ),
                GoRoute(
                  path: 'user/:uid',
                  builder: (context, state) => PublicProfilePage(
                    uid: state.pathParameters['uid']!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
          GoRoute(
              path: AppRoutes.exchanges,
              builder: (context, state) => const ExchangesPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
  );
}