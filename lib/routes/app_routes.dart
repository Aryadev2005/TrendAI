import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/onboarding/smart_onboarding_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/discover/discover_screen.dart';
import '../presentation/screens/agent/agent_chat_screen.dart';
import '../presentation/screens/launch/launch_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const splash     = '/';
  static const login      = '/login';
  static const signup     = '/signup';
  static const onboarding = '/onboarding';
  static const dashboard  = '/home';
  static const discover   = '/discover';
  static const studio     = '/studio';   // → AgentChatScreen (ARIA is the Studio)
  static const launch     = '/launch';
  static const profile    = '/profile';
  static const calendar   = '/home';     // calendar lives on dashboard for now

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: login,      builder: (_, __) => const LoginScreen()),
      GoRoute(path: signup,     builder: (_, __) => const SignupScreen()),
      GoRoute(path: onboarding, builder: (_, __) => const SmartOnboardingScreen()),
      GoRoute(path: dashboard,  builder: (_, __) => const DashboardScreen()),
      GoRoute(path: discover,   builder: (_, __) => const DiscoverScreen()),
      GoRoute(path: studio,     builder: (_, __) => const AgentChatScreen()),
      GoRoute(path: launch,     builder: (_, __) => const LaunchScreen()),
      GoRoute(path: profile,    builder: (_, __) => const ProfileScreen()),
    ],
  );
}