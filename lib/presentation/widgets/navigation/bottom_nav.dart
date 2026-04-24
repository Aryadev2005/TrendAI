import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', route: AppRoutes.dashboard),
      _NavItem(icon: Icons.trending_up, label: 'Trends', route: AppRoutes.trends),
      _NavItem(icon: Icons.auto_awesome, label: 'Create', route: AppRoutes.create),
      _NavItem(icon: Icons.person_outline, label: 'Profile', route: AppRoutes.profile),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => context.go(items[i].route),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].icon, color: active ? AppColors.primary : AppColors.textMuted, size: 24),
                const SizedBox(height: 4),
                Text(items[i].label, style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}