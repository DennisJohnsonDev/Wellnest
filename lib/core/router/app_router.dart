import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/session_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/cme/presentation/certificate_screen.dart';
import '../../features/cme/presentation/cme_screen.dart';
import '../../features/cme/presentation/course_detail_screen.dart';
import '../../features/cme/presentation/widgets/course_card.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/library/presentation/article_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/licence/presentation/licence_screen.dart';
import '../../features/licence/presentation/renewal_complete_screen.dart';
import '../../features/licence/presentation/renewal_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';
import 'branch_switcher.dart';
import 'expand_page.dart';
import 'fade_page.dart';
import 'hud_page.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final signedIn = ValueNotifier(ref.read(sessionProvider));
  ref
    ..listen(sessionProvider, (_, next) => signedIn.value = next)
    ..onDispose(signedIn.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: signedIn,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublic = AppRoutes.public.contains(location);
      if (!signedIn.value) return isPublic ? null : AppRoutes.signIn;
      return location == AppRoutes.signIn ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            FadePage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            FadePage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        pageBuilder: (context, state) =>
            FadePage(key: state.pageKey, child: const SignInScreen()),
      ),
      StatefulShellRoute(
        pageBuilder: (context, state, shell) => FadePage(
          key: state.pageKey,
          duration: const Duration(milliseconds: 760),
          child: AppShell(shell: shell),
        ),
        navigatorContainerBuilder: (context, shell, children) =>
            BranchSwitcher(index: shell.currentIndex, children: children),
        branches: [
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.licence, const LicenceScreen()),
          _branch(AppRoutes.cme, const CmeScreen()),
          _branch(AppRoutes.library, const LibraryScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.renewal,
        pageBuilder: (context, state) =>
            HudPage(key: state.pageKey, child: const RenewalScreen()),
      ),
      GoRoute(
        path: AppRoutes.renewalComplete,
        pageBuilder: (context, state) =>
            FadePage(key: state.pageKey, child: const RenewalCompleteScreen()),
      ),
      GoRoute(
        path: '/course/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final detail = CourseDetailScreen(courseId: id);
          return switch (state.extra) {
            final Rect origin => ExpandPage(
              key: state.pageKey,
              origin: origin,
              from: LiveCourseCard(courseId: id),
              child: detail,
            ),
            _ => HudPage(key: state.pageKey, child: detail),
          };
        },
        routes: [
          GoRoute(
            path: 'certificate',
            pageBuilder: (context, state) => FadePage(
              key: state.pageKey,
              child: CertificateScreen(courseId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/article/:id',
        pageBuilder: (context, state) => HudPage(
          key: state.pageKey,
          child: ArticleScreen(articleId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) =>
            HudPage(key: state.pageKey, child: const ProfileScreen()),
      ),
    ],
  );
  ref.onDispose(router.dispose);

  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: screen),
    ),
  ],
);
