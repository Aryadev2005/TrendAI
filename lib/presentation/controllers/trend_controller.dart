import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trend_model.dart';
import '../../data/repositories/trend_repository.dart';

class TrendState {
  final List<TrendModel> trends;
  final bool isLoading;
  final String? error;

  const TrendState({
    this.trends = const [],
    this.isLoading = false,
    this.error,
  });

  TrendState copyWith({
    List<TrendModel>? trends,
    bool? isLoading,
    String? error,
  }) {
    return TrendState(
      trends: trends ?? this.trends,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TrendController extends StateNotifier<TrendState> {
  final TrendRepository _repo;
  TrendController(this._repo) : super(const TrendState());

  Future<void> fetchTrends({
    required String niche,
    String? platform,
    String? followerRange,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trends = await _repo.fetchTrends(
        niche: niche,
        platform: platform,
        followerRange: followerRange,
      );
      state = state.copyWith(trends: trends, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> filterByBadge(String badge) async {
    state = state.copyWith(isLoading: true);
    try {
      final filtered = await _repo.fetchByBadge(badge);
      state = state.copyWith(trends: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final trendRepositoryProvider = Provider((ref) => TrendRepository());

final trendProvider = StateNotifierProvider<TrendController, TrendState>(
  (ref) => TrendController(ref.read(trendRepositoryProvider)),
);