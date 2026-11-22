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
  static const messages = '/messages';

  static String chat(String otherUid, String name) => Uri(
        path: '$messages/chat/$otherUid',
        queryParameters: {'name': name},
      ).toString();
  static String userProfile(String uid) => '$discover/user/$uid';
}