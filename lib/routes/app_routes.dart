import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/controllers/auth_controller.dart';

// Auth screens
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/onboarding_screen.dart';

// Main screens
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/discover/discover_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

// Placeholder screens for Studio + Launch (built on Day 7 & 9)
import '../presentation/screens/studio/studio_screen_placeholder.dart';
import '../presentation/screens/launch/launch_screen_placeholder.dart';

class AppRoutes {
  // Auth
  static const splash     = '/';
  static const login      = '/login';
  static const signup     = '/signup';
  static const onboarding = '/onboarding';

  // Main ARIA phases
  static const dashboard = '/home';
  static const discover  = '/discover';
  static const studio    = '/studio';
  static const launch    = '/launch';
  static const profile   = '/profile';

  // Legacy routes (keep for backward compat)
  static const trends = '/trends';
  static const songs  = '/songs';
  static const create = '/create';

  static GoRouter createRouter(ProviderContainer container) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final authState = container.read(authProvider);
        final isAuth = authState.isAuthenticated;
        final loc = state.matchedLocation;
        final isOnAuthPage = loc == login || loc == signup || loc == splash;

        if (isAuth && isOnAuthPage && loc != splash) {
          return dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(path: splash,     builder: (_, __) => const SplashScreen()),
        GoRoute(path: login,      builder: (_, __) => const LoginScreen()),
        GoRoute(path: signup,     builder: (_, __) => const SignupScreen()),
        GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: dashboard,  builder: (_, __) => const DashboardScreen()),
        GoRoute(path: discover,   builder: (_, __) => const DiscoverScreen()),
        GoRoute(path: studio,     builder: (_, __) => const StudioScreenPlaceholder()),
        GoRoute(path: launch,     builder: (_, __) => const LaunchScreenPlaceholder()),
        GoRoute(path: profile,    builder: (_, __) => const ProfileScreen()),
      ],
    );
  }

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: login,      builder: (_, __) => const LoginScreen()),
      GoRoute(path: signup,     builder: (_, __) => const SignupScreen()),
      GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: dashboard,  builder: (_, __) => const DashboardScreen()),
      GoRoute(path: discover,   builder: (_, __) => const DiscoverScreen()),
      GoRoute(path: studio,     builder: (_, __) => const StudioScreenPlaceholder()),
      GoRoute(path: launch,     builder: (_, __) => const LaunchScreenPlaceholder()),
      GoRoute(path: profile,    builder: (_, __) => const ProfileScreen()),
    ],
  );
}