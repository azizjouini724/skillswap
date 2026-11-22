import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skillswap/core/routes/app_routes.dart';
import 'package:skillswap/core/routes/go_router_refresh_stream.dart';
import 'package:skillswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:skillswap/features/auth/presentation/pages/login_page.dart';
import 'package:skillswap/features/auth/presentation/pages/register_page.dart';
import 'package:skillswap/features/auth/presentation/pages/welcome_page.dart';
import 'package:skillswap/features/home/presentation/pages/home_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Firebase n'a pas encore donné l'état de connexion.
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}