import 'package:trendai/data/services/api_client.dart';
import 'package:trendai/data/models/content_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Content Service - AI content generation and history
// ─────────────────────────────────────────────────────────────────────────────

class ContentService {
  static final ContentService _instance = ContentService._internal();
  final ApiClient _apiClient = ApiClient();

  factory ContentService() {
    return _instance;
  }

  ContentService._internal();

  // ─────────────────────────────────────────────────────────────────────────
  // POST /content/generate
  // Generates AI content (hook, caption, hashtags, etc.)
  // ─────────────────────────────────────────────────────────────────────────
  Future<ContentModel> generateContent({
    required String trendTitle,
    required String platform,
    String niche = 'fashion',
    String? songTitle,
    String tone = 'casual',
    String language = 'hinglish',
  }) async {
    try {
      final response = await _apiClient.post(
        '/content/generate',
        data: {
          'trendTitle': trendTitle,
          'platform': platform,
          'niche': niche,
          'songTitle': songTitle,
          'tone': tone,
          'language': language,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return ContentModel.fromMap(response['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        error: response['error'] ?? 'GENERATE_CONTENT_FAILED',
        message: response['message'] ?? 'Failed to generate content',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POST /content/hooks
  // Generates multiple hook options for a topic
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<String>> generateHooks({
    required String topic,
    required String platform,
    String? niche,
  }) async {
    try {
      final data = {
        'topic': topic,
        'platform': platform,
      };
      if (niche != null) data['niche'] = niche;

      final response = await _apiClient.post(
        '/content/hooks',
        data: data,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> hooks = response['data'];
        return hooks.map((h) => h.toString()).toList();
      }

      throw ApiException(
        error: response['error'] ?? 'GENERATE_HOOKS_FAILED',
        message: response['message'] ?? 'Failed to generate hooks',
      );
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GET /content/history
  // Fetches user's generated content history
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<ContentModel>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/content/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> contentList = response['data'];
        return contentList
            .map((item) => ContentModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        error: response['error'] ?? 'FETCH_CONTENT_HISTORY_FAILED',
        message: response['message'] ?? 'Failed to fetch content history',
      );
    } catch (e) {
      rethrow;
    }
  }
}
