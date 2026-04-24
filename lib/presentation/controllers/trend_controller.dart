import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trend_model.dart';

class TrendState {
  final List<TrendModel> trends;
  final bool isLoading;
  final String? error;

  const TrendState({this.trends = const [], this.isLoading = false, this.error});

  TrendState copyWith({List<TrendModel>? trends, bool? isLoading, String? error}) {
    return TrendState(
      trends: trends ?? this.trends,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrendController extends StateNotifier<TrendState> {
  TrendController() : super(const TrendState());

  Future<void> fetchTrends(String niche) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock data — replace with real API later
      final trends = [
        TrendModel(id: '1', title: 'Quiet Luxury Outfits', platform: 'Instagram Reels', stat: '2.4M views', badge: 'HOT', aiTip: 'Post a GRWM Reel using neutral tones. Add #QuietLuxury', detectedAt: DateTime.now(), isPersonalized: true),
        TrendModel(id: '2', title: 'Winter Capsule Wardrobe', platform: 'YouTube Shorts', stat: '+180% this week', badge: 'RISING', aiTip: '"5 pieces for a whole month" style — high saves content', detectedAt: DateTime.now()),
        TrendModel(id: '3', title: 'Day in my life vlog', platform: 'TikTok', stat: 'New trend', badge: 'NEW', aiTip: 'Raw unfiltered content is getting 3x more DMs', detectedAt: DateTime.now()),
        TrendModel(id: '4', title: 'Behind the scenes', platform: 'Instagram Stories', stat: '890K views', badge: 'RISING', aiTip: 'Show your real workspace — authenticity wins right now', detectedAt: DateTime.now()),
      ];
      state = state.copyWith(trends: trends, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final trendProvider = StateNotifierProvider<TrendController, TrendState>(
  (ref) => TrendController(),
);