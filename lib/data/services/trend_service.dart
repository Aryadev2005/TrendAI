import 'package:trendai/data/services/api_client.dart';
import 'package:trendai/data/models/trend_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Trend Service - Fetches trends, saves/unsaves trends
// ─────────────────────────────────────────────────────────────────────────────

class TrendService {
  static final TrendService _instance = TrendService._internal();
  final ApiClient _apiClient = ApiClient();

  factory TrendService() {
    return _instance;
  }

  TrendService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // GET /trends
  // Fetches trends with optional filters
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<TrendModel>> getTrends({
    String niche = 'fashion',
    String platform = 'instagram',
    String badge = 'ALL',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/trends',
        queryParameters: {
          'niche': niche,
          'platform': platform,
          'badge': badge,
          'page': page,
          'limit': limit,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> trendList = response['data'];
        return trendList
            .map((item) => TrendModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_TRENDS_FAILED',
        message: response['message'] ?? 'Failed to fetch trends',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /trends/personalized
  // Fetches AI-personalized trends for authenticated user
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<TrendModel>> getPersonalizedTrends() async {
    try {
      final response = await _apiClient.get('/trends/personalized');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> trendList = response['data'];
        return trendList
            .map((item) => TrendModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_PERSONALIZED_TRENDS_FAILED',
        message: response['message'] ?? 'Failed to fetch personalized trends',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /trends/:id/save
  // Saves a trend to user's saved list
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> saveTrend(String trendId) async {
    try {
      final response = await _apiClient.post('/trends/$trendId/save');

      if (response['success'] != true) {
        throw ApiException(
          error: response['error'] ?? 'SAVE_TREND_FAILED',
          message: response['message'] ?? 'Failed to save trend',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /trends/saved/list
  // Fetches user's saved trends
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<TrendModel>> getSavedTrends() async {
    try {
      final response = await _apiClient.get('/trends/saved/list');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> trendList = response['data'];
        return trendList
            .map((item) => TrendModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_SAVED_TRENDS_FAILED',
        message: response['message'] ?? 'Failed to fetch saved trends',
      );
    } catch (e) {
      rethrow;
    }
  }
}
