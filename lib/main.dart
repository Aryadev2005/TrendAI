import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trendai/core/theme/app_theme.dart'; 
import 'routes/app_routes.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrendAIApp(),
    ),
  );
}

class TrendAIApp extends StatelessWidget {
  const TrendAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrendAI',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      theme: AppTheme.darkTheme,
    );
  }
}