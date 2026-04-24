import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/cards/stat_card.dart';
import '../../../presentation/widgets/cards/trend_card.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/trend_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(trendProvider.notifier).fetchTrends('fashion'));
  }

  @override
  Widget build(BuildContext context) {
    final trendState = ref.watch(trendProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Positioned(top: -80, right: -60, child: Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.08)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(userName),
                  const SizedBox(height: 24),
                  Row(children: const [
                    StatCard(value: '24.5K', label: 'Followers', change: '+2.4%', isPositive: true),
                    SizedBox(width: 10),
                    StatCard(value: '4.8%', label: 'Engagement', change: '+0.6%', isPositive: true),
                    SizedBox(width: 10),
                    StatCard(value: '12', label: 'Posts/mo', change: '-1', isPositive: false),
                  ]),
                  const SizedBox(height: 24),
                  _aiCard(),
                  const SizedBox(height: 24),
                  _sectionHeader('Trending for you'),
                  const SizedBox(height: 16),
                  if (trendState.isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else
                    ...trendState.trends.take(3).map((t) => TrendCard(trend: t)),
                ],
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(currentIndex: 0)),
        ],
      ),
    );
  }

  Widget _topBar(String name) => Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good morning 👋', style: TextStyle(color: AppColors.textMuted, fontSize: AppDimensions.fontSM)),
          const SizedBox(height: 2),
          Text('Hi, $name!', style: const TextStyle(color: Colors.white, fontSize: AppDimensions.fontXL, fontWeight: FontWeight.bold)),
        ],
      ),
      const Spacer(),
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15), border: Border.all(color: AppColors.primary.withOpacity(0.4))),
        child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
      ),
    ],
  );

  Widget _aiCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)), child: const Text('AI RECOMMENDS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
          const Spacer(),
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
        ]),
        const SizedBox(height: 14),
        const Text('"Quiet Luxury" aesthetic Reels are\ngetting 3.2x more engagement this week', style: TextStyle(color: Colors.white, fontSize: AppDimensions.fontMD, fontWeight: FontWeight.w600, height: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.access_time, color: Colors.white38, size: 14),
          const SizedBox(width: 6),
          const Text('Best time: Today 7–9 PM IST', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)), child: const Text('Create now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: AppDimensions.fontLG, fontWeight: FontWeight.bold)),
      Text('See all', style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: AppDimensions.fontSM)),
    ],
  );
}