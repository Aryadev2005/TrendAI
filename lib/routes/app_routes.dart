import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/auth/onboarding_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/trends/trends_screen.dart';
import '../presentation/screens/songs/songs_screen.dart';
import '../presentation/screens/create/create_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const trends = '/trends';
  static const songs = '/songs';
  static const create = '/create';
  static const profile = '/profile';

  static GoRouter createRouter(ProviderContainer container) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final authState =
            container.read(authProvider);
        final isAuth = authState.isAuthenticated;
        final isOnAuthPage =
            state.matchedLocation == login ||
            state.matchedLocation == signup ||
            state.matchedLocation == splash;

        // If authenticated and trying to access auth pages
        // redirect to dashboard
        if (isAuth && isOnAuthPage &&
            state.matchedLocation != splash) {
          return dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(
            path: splash,
            builder: (_, __) => const SplashScreen()),
        GoRoute(
            path: login,
            builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: signup,
            builder: (_, __) => const SignupScreen()),
        GoRoute(
            path: onboarding,
            builder: (_, __) => const OnboardingScreen()),
        GoRoute(
            path: dashboard,
            builder: (_, __) => const DashboardScreen()),
        GoRoute(
            path: trends,
            builder: (_, __) => const TrendsScreen()),
        GoRoute(
            path: songs,
            builder: (_, __) => const SongsScreen()),
        GoRoute(
            path: create,
            builder: (_, __) => const CreateScreen()),
        GoRoute(
            path: profile,
            builder: (_, __) => const ProfileScreen()),
      ],
    );
  }

  // Keep simple router for backward compatibility
  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
          path: splash,
          builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: login,
          builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: signup,
          builder: (_, __) => const SignupScreen()),
      GoRoute(
          path: onboarding,
          builder: (_, __) => const OnboardingScreen()),
      GoRoute(
          path: dashboard,
          builder: (_, __) => const DashboardScreen()),
      GoRoute(
          path: trends,
          builder: (_, __) => const TrendsScreen()),
      GoRoute(
          path: songs,
          builder: (_, __) => const SongsScreen()),
      GoRoute(
          path: create,
          builder: (_, __) => const CreateScreen()),
      GoRoute(
          path: profile,
          builder: (_, __) => const ProfileScreen()),
    ],
  );
}