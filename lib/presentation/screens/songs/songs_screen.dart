import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trendai/data/providers/api_providers.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../presentation/widgets/cards/song_card.dart';
import '../../../presentation/widgets/navigation/bottom_nav.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});
  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  String selectedNiche = 'fashion';

  @override
  Widget build(BuildContext context) {
    // Fetch top 10 songs for selected niche
    final songsAsync = ref.watch(top10SongsProvider(selectedNiche));

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
                      const Text(
                        'Trending Sounds',
                        style: TextStyle(
                          fontSize: AppDimensions.fontXXL,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Top 10 songs for $selectedNiche creators',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: AppDimensions.fontSM,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Niche selector
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['fashion', 'lifestyle', 'comedy', 'music']
                              .map((niche) {
                            final sel = selectedNiche == niche;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedNiche = niche),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.primary
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: sel
                                        ? AppColors.primary
                                        : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  niche.replaceFirst(
                                    niche[0],
                                    niche[0].toUpperCase(),
                                  ),
                                  style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize: AppDimensions.fontSM,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: songsAsync.when(
                    data: (songs) {
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: songs.length,
                        itemBuilder: (_, i) => SongCard(
                          song: songs[i],
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error loading songs: $err',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNav(currentIndex: 3),
          ),
        ],
      ),
    );
  }
}
