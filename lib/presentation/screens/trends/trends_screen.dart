import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/cards/trend_card.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';
import '../../../presentation/controllers/trend_controller.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});
  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'HOT', 'RISING', 'NEW'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(trendProvider.notifier).fetchTrends('fashion'));
  }

  @override
  Widget build(BuildContext context) {
    final trendState = ref.watch(trendProvider);
    final filtered = selectedFilter == 'All'
        ? trendState.trends
        : trendState.trends.where((t) => t.badge == selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trending Now', style: TextStyle(fontSize: AppDimensions.fontXXL, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Updated 2 min ago', style: TextStyle(color: AppColors.textMuted, fontSize: AppDimensions.fontSM)),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filters.map((f) {
                            final sel = selectedFilter == f;
                            return GestureDetector(
                              onTap: () => setState(() => selectedFilter = f),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  border: Border.all(color: sel ? AppColors.primary : Colors.white12),
                                ),
                                child: Text(f, style: TextStyle(color: sel ? Colors.white : AppColors.textMuted, fontSize: AppDimensions.fontSM, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: trendState.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => TrendCard(trend: filtered[i]),
                        ),
                ),
              ],
            ),
          ),
          const Positioned(bottom: 0, left: 0, right: 0, child: BottomNav(currentIndex: 1)),
        ],
      ),
    );
  }
}