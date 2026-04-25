import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';

class SongState {
  final List<SongModel> songs;
  final bool isLoading;
  final String? error;

  const SongState({
    this.songs = const [],
    this.isLoading = false,
    this.error,
  });

  SongState copyWith({
    List<SongModel>? songs,
    bool? isLoading,
    String? error,
  }) {
    return SongState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SongController extends StateNotifier<SongState> {
  final SongRepository _repo;
  SongController(this._repo) : super(const SongState());

  Future<void> fetchSongs({
    required String niche,
    String? platform,
    String? followerRange,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final songs = await _repo.fetchTopSongs(
        niche: niche,
        platform: platform,
        followerRange: followerRange,
      );
      state = state.copyWith(songs: songs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> filterByBadge(String badge) async {
    state = state.copyWith(isLoading: true);
    try {
      final filtered = await _repo.fetchByBadge(badge);
      state = state.copyWith(songs: filtered, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final songRepositoryProvider = Provider((ref) => SongRepository());

final songProvider = StateNotifierProvider<SongController, SongState>(
  (ref) => SongController(ref.read(songRepositoryProvider)),
);
