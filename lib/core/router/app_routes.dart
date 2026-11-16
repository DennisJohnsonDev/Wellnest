abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const home = '/home';
  static const licence = '/licence';
  static const cme = '/cme';
  static const library = '/library';
  static const renewal = '/renewal';
  static const renewalComplete = '/renewed';
  static const profile = '/profile';

  static const public = {splash, onboarding, signIn};

  static String course(String id) => '/course/$id';

  static String certificate(String id) => '/course/$id/certificate';

  static String article(String id) => '/article/$id';
}
