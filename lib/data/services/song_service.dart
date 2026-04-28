import 'package:trendai/data/services/api_client.dart';
import 'package:trendai/data/models/song_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Song Service - Fetches trending and top songs
// ─────────────────────────────────────────────────────────────────────────────

class SongService {
  static final SongService _instance = SongService._internal();
  final ApiClient _apiClient = ApiClient();

  factory SongService() {
    return _instance;
  }

  SongService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // GET /songs
  // Fetches songs with optional filters
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<SongModel>> getSongs({
    String? niche,
    String? lifecycle,
    String? signal,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (niche != null) queryParams['niche'] = niche;
      if (lifecycle != null) queryParams['lifecycle'] = lifecycle;
      if (signal != null) queryParams['signal'] = signal;

      final response = await _apiClient.get(
        '/songs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> songList = response['data'];
        return songList
            .map((item) => SongModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_SONGS_FAILED',
        message: response['message'] ?? 'Failed to fetch songs',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /songs/top10
  // Fetches top 10 songs for a specific niche
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<SongModel>> getTop10Songs(String niche) async {
    try {
      final response = await _apiClient.get(
        '/songs/top10',
        queryParameters: {'niche': niche},
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> songList = response['data'];
        return songList
            .map((item) => SongModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_TOP10_SONGS_FAILED',
        message: response['message'] ?? 'Failed to fetch top 10 songs',
      );
    } catch (e) {
      rethrow;
    }
  }
}
