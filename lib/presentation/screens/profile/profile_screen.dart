import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15), border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2)),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'Influencer', style: const TextStyle(color: Colors.white, fontSize: AppDimensions.fontXL, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.white38, fontSize: AppDimensions.fontSM)),
                  const SizedBox(height: 8),
                  if (user?.primaryPlatform != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.4))),
                      child: Text(user!.primaryPlatform!, style: const TextStyle(color: AppColors.primary, fontSize: AppDimensions.fontSM)),
                    ),
                  const SizedBox(height: 32),
                  _menuItem(Icons.trending_up, 'My Trends', 'View saved trends', () {}),
                  _menuItem(Icons.history, 'Content History', 'Past generated content', () {}),
                  _menuItem(Icons.notifications_outlined, 'Notifications', 'Manage alerts', () {}),
                  _menuItem(Icons.language, 'Language', 'English / Hindi', () {}),
                  _menuItem(Icons.star_outline, 'Upgrade to Pro', 'Unlock all features', () {}, highlight: true),
                  _menuItem(Icons.logout, 'Logout', '', () {
                    ref.read(authProvider.notifier).logout();
                    context.go(AppRoutes.login);
                  }, isDestructive: true),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(currentIndex: 4)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool highlight = false, bool isDestructive = false}) {
    final color = isDestructive ? Colors.red.shade400 : highlight ? AppColors.primary : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: highlight ? AppColors.primary.withOpacity(0.3) : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: AppDimensions.fontMD, fontWeight: FontWeight.w500)),
                  if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: AppDimensions.fontXS)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}