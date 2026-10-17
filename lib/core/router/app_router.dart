import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/scanner/presentation/pages/scanner_page.dart';
import '../../features/splash/presentation/pages/onboarding_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../navigation/app_shell.dart';
import 'app_routes.dart';

/// Declarative route table. URLs are first-class on the web, so every main
/// screen is deep-linkable (`/dashboard`, `/scanner`, `/marketplace`).
abstract final class AppRouter {
  static GoRouter create({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splash,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage<void>(
                key: state.pageKey,
                child: const SplashPage(),
              ),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              CustomTransitionPage<void>(
                key: state.pageKey,
                child: const OnboardingPage(),
                transitionDuration: const Duration(milliseconds: 900),
                transitionsBuilder: _dissolve,
              ),
        ),
        StatefulShellRoute.indexedStack(
          pageBuilder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: AppShell(navigationShell: navigationShell),
                transitionDuration: const Duration(milliseconds: 1000),
                transitionsBuilder: _ornamentReveal,
              ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.dashboard,
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      const NoTransitionPage<void>(child: DashboardPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.scanner,
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      const NoTransitionPage<void>(child: ScannerPage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoutes.marketplace,
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      const NoTransitionPage<void>(child: MarketplacePage()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Splash → onboarding: fade with a gentle de-zoom.
  static Widget _dissolve(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.06, end: 1).animate(curved),
        child: child,
      ),
    );
  }

  /// Onboarding → app: a circular "lens" reveal opening from the centre,
  /// like the scanner aperture opening onto the platform.
  static Widget _ornamentReveal(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (BuildContext context, Widget? child) {
        if (curved.value >= 1) return child!;
        return ClipPath(
          clipper: _CircleRevealClipper(curved.value),
          child: Opacity(
            opacity: (curved.value * 1.6).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  const _CircleRevealClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final Offset center = size.center(Offset.zero);
    final double maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * fraction));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
