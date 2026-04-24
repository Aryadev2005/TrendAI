import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/onboarding_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/trends/trends_screen.dart';
import '../presentation/screens/create/create_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const trends = '/trends';
  static const create = '/create';
  static const profile = '/profile';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: dashboard, builder: (_, __) => const DashboardScreen()),
      GoRoute(path: trends, builder: (_, __) => const TrendsScreen()),
      GoRoute(path: create, builder: (_, __) => const CreateScreen()),
      GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
    ],
  );
}