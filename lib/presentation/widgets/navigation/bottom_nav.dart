// lib/presentation/widgets/navigation/bottom_nav.dart
// ARIA bottom nav — 5 tabs: Home / Discover / Studio / Launch / Profile

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded,           label: 'Home',    route: AppRoutes.dashboard),
      _NavItem(icon: Icons.explore_rounded,         label: 'Discover', route: AppRoutes.discover),
      _NavItem(icon: Icons.auto_fix_high_rounded,   label: 'Studio',  route: AppRoutes.studio),
      _NavItem(icon: Icons.rocket_launch_rounded,   label: 'Launch',  route: AppRoutes.launch),
      _NavItem(icon: Icons.person_rounded,          label: 'Profile', route: AppRoutes.profile),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => context.go(items[i].route),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i].icon,
                    color: active ? AppColors.primary : AppColors.textMid,
                    size: 22,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    child: active
                        ? Row(children: [
                            const SizedBox(width: 6),
                            Text(
                              items[i].label,
                              style: GoogleFonts.dmSans(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
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