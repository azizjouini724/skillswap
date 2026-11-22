class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const discover = '/discover';
  static const exchanges = '/exchanges';
  static const profile = '/profile';
  static const matches = '/discover/matches';
  static const notifications = '/home/notifications';
  static String userProfile(String uid) => '$discover/user/$uid';
}