import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trendai/data/models/trend_model.dart';
import 'package:trendai/data/models/song_model.dart';
import 'package:trendai/data/models/content_model.dart';
import 'package:trendai/data/services/trend_service.dart';
import 'package:trendai/data/services/song_service.dart';
import 'package:trendai/data/services/content_service.dart';
import 'package:trendai/data/services/analytics_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Service Providers (Singletons)
// ─────────────────────────────────────────────────────────────────────────────

final trendServiceProvider = Provider((ref) => TrendService());
final songServiceProvider = Provider((ref) => SongService());
final contentServiceProvider = Provider((ref) => ContentService());
final analyticsServiceProvider = Provider((ref) => AnalyticsService());

// ─────────────────────────────────────────────────────────────────────────────
// Trends Providers
// ─────────────────────────────────────────────────────────────────────────────

// FutureProvider for getTrends with filters
final trendsProvider = FutureProvider.family<List<TrendModel>,
    ({String niche, String platform, String badge, int page, int limit})>(
  (ref, params) async {
    final service = ref.watch(trendServiceProvider);
    return service.getTrends(
      niche: params.niche,
      platform: params.platform,
      badge: params.badge,
      page: params.page,
      limit: params.limit,
    );
  },
);

// FutureProvider for personalized trends
final personalizedTrendsProvider = FutureProvider<List<TrendModel>>((ref) async {
  final service = ref.watch(trendServiceProvider);
  return service.getPersonalizedTrends();
});

// FutureProvider for saved trends
final savedTrendsProvider = FutureProvider<List<TrendModel>>((ref) async {
  final service = ref.watch(trendServiceProvider);
  return service.getSavedTrends();
});

// ─────────────────────────────────────────────────────────────────────────────
// Songs Providers
// ─────────────────────────────────────────────────────────────────────────────

// FutureProvider for getSongs with optional filters
final songsProvider = FutureProvider.family<List<SongModel>,
    ({String? niche, String? lifecycle, String? signal})>(
  (ref, params) async {
    final service = ref.watch(songServiceProvider);
    return service.getSongs(
      niche: params.niche,
      lifecycle: params.lifecycle,
      signal: params.signal,
    );
  },
);

// FutureProvider for top 10 songs
final top10SongsProvider = FutureProvider.family<List<SongModel>, String>(
  (ref, niche) async {
    final service = ref.watch(songServiceProvider);
    return service.getTop10Songs(niche);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Content Providers
// ─────────────────────────────────────────────────────────────────────────────

// StateNotifierProvider for content generation (holds loading/result state)
class GenerateContentState {
  final bool isLoading;
  final ContentModel? result;
  final String? error;

  GenerateContentState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  GenerateContentState copyWith({
    bool? isLoading,
    ContentModel? result,
    String? error,
  }) {
    return GenerateContentState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
    );
  }
}

class GenerateContentNotifier extends StateNotifier<GenerateContentState> {
  final ContentService _contentService;

  GenerateContentNotifier(this._contentService)
      : super(GenerateContentState());

  Future<void> generateContent({
    required String trendTitle,
    required String platform,
    String niche = 'fashion',
    String? songTitle,
    String tone = 'casual',
    String language = 'hinglish',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final content = await _contentService.generateContent(
        trendTitle: trendTitle,
        platform: platform,
        niche: niche,
        songTitle: songTitle,
        tone: tone,
        language: language,
      );
      state = state.copyWith(isLoading: false, result: content);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearContent() {
    state = GenerateContentState();
  }
}

final generateContentProvider =
    StateNotifierProvider<GenerateContentNotifier, GenerateContentState>(
  (ref) => GenerateContentNotifier(ref.watch(contentServiceProvider)),
);

// FutureProvider for content history
final contentHistoryProvider = FutureProvider.family<List<ContentModel>,
    ({int page, int limit})>(
  (ref, params) async {
    final service = ref.watch(contentServiceProvider);
    return service.getHistory(page: params.page, limit: params.limit);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Providers
// ─────────────────────────────────────────────────────────────────────────────

// FutureProvider for dashboard
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getDashboard();
});

// FutureProvider for best times to post
final bestTimesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getBestTimes();
});
