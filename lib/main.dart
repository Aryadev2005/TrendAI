import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: TrendAIApp()));
}

class TrendAIApp extends ConsumerWidget {
  const TrendAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final container = ProviderScope.containerOf(context);
    return MaterialApp.router(
      title: 'TrendAI',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.createRouter(container),
      theme: AppTheme.warmTheme,
    );
  }
}