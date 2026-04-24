import '../models/trend_model.dart';
import '../services/api_service.dart';

class TrendRepository {
  // ─── Fetch trends (mock → real API later) ─────────────────────────────────
  Future<List<TrendModel>> fetchTrends({
    required String niche,
    String? platform,
    String? followerRange,
  }) async {
    try {
      // Try Claude API for personalised trend insights
      final aiInsights = await ApiService.getTrendInsights(
        niche: niche,
        platform: platform ?? 'Instagram',
        followerRange: followerRange ?? '10K–50K',
      );
      return aiInsights;
    } catch (_) {
      // Fallback to curated mock data
      return _mockTrends(niche);
    }
  }

  // ─── Fetch trending by badge ──────────────────────────────────────────────
  Future<List<TrendModel>> fetchByBadge(String badge) async {
    final all = await fetchTrends(niche: 'general');
    if (badge == 'All') return all;
    return all.where((t) => t.badge == badge).toList();
  }

  // ─── Mock data (India-first content) ─────────────────────────────────────
  List<TrendModel> _mockTrends(String niche) {
    return [
      TrendModel(
        id: '1',
        title: 'Quiet Luxury Outfits',
        platform: 'Instagram Reels',
        stat: '2.4M views',
        badge: 'HOT',
        aiTip: 'Post a GRWM Reel with neutral tones. Add #QuietLuxury',
        detectedAt: DateTime.now(),
        isPersonalized: true,
      ),
      TrendModel(
        id: '2',
        title: 'Winter Capsule Wardrobe',
        platform: 'YouTube Shorts',
        stat: '+180% this week',
        badge: 'RISING',
        aiTip: '"5 pieces for a whole month" — high-saves content format',
        detectedAt: DateTime.now(),
      ),
      TrendModel(
        id: '3',
        title: 'Day in My Life Vlog',
        platform: 'TikTok',
        stat: 'New trend',
        badge: 'NEW',
        aiTip: 'Raw, unfiltered content is getting 3x more DMs right now',
        detectedAt: DateTime.now(),
      ),
      TrendModel(
        id: '4',
        title: 'Behind the Scenes',
        platform: 'Instagram Stories',
        stat: '890K views',
        badge: 'RISING',
        aiTip: 'Show your real workspace — authenticity wins right now',
        detectedAt: DateTime.now(),
      ),
      TrendModel(
        id: '5',
        title: 'Budget Dupes Haul',
        platform: 'Instagram Reels',
        stat: '1.1M views',
        badge: 'HOT',
        aiTip: 'Meesho + Myntra dupes are trending hard. Show price tags!',
        detectedAt: DateTime.now(),
        isPersonalized: true,
      ),
      TrendModel(
        id: '6',
        title: 'Saree Styling 2025',
        platform: 'YouTube',
        stat: '+240% searches',
        badge: 'RISING',
        aiTip: 'Fusion saree + western top combos performing best in metros',
        detectedAt: DateTime.now(),
      ),
    ];
  }
}
