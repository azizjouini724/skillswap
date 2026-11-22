import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const _TempPage('Welcome'),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const _TempPage('Login'),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const _TempPage('Register'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _TempPage('Home'),
    ),
  ],
);

class _TempPage extends StatelessWidget {
  final String title;
  const _TempPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 28))),
    );
  }
}