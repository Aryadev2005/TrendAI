import 'package:trendai/data/services/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Analytics Service - Dashboard and best times to post
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  final ApiClient _apiClient = ApiClient();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // GET /analytics/dashboard
  // Fetches user's analytics dashboard data
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _apiClient.get('/analytics/dashboard');

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_DASHBOARD_FAILED',
        message: response['message'] ?? 'Failed to fetch dashboard data',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /analytics/best-times
  // Fetches best times to post for user's audience
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBestTimes() async {
    try {
      final response = await _apiClient.get('/analytics/best-times');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> timesList = response['data'];
        return timesList
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_BEST_TIMES_FAILED',
        message: response['message'] ?? 'Failed to fetch best times',
      );
    } catch (e) {
      rethrow;
    }
  }
}
