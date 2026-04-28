import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trend_model.dart';

class ApiService {
  static const _baseUrl = 'http://localhost:3000/api/v1';

  // ─── Headers ──────────────────────────────────────────────────────────────
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // ─── Generate Content ─────────────────────────────────────────────────────
  static Future<String> generateContent({
    required String trendTitle,
    required String niche,
    required String platform,
    required String followerRange,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/content/generate'),
      headers: _headers,
      body: jsonEncode({
        'trendTitle': trendTitle,
        'niche': niche,
        'platform': platform,
        'followerRange': followerRange,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Content generation failed: ${response.statusCode}');
    }
  }

  // ─── Get Trend Insights ───────────────────────────────────────────────────
  static Future<List<TrendModel>> getTrendInsights({
    required String niche,
    required String platform,
    required String followerRange,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trends'),
      headers: _headers,
      body: jsonEncode({
        'niche': niche,
        'platform': platform,
        'followerRange': followerRange,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Trend fetch failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final raw = data['data'] ?? data;

    final List<dynamic> list = jsonDecode(raw);
    return list.map((item) => TrendModel.fromMap({
      ...item as Map<String, dynamic>,
      'detectedAt': DateTime.now().toIso8601String(),
    })).toList();
  }

  // ─── Get Top Songs ────────────────────────────────────────────────────────
  static Future<dynamic> getTopSongs({
    required String niche,
    required String platform,
    required String followerRange,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/songs'),
      headers: _headers,
      body: jsonEncode({
        'niche': niche,
        'platform': platform,
        'followerRange': followerRange,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Song fetch failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['data'] ?? data;
  }

  // ─── Analyse engagement potential ─────────────────────────────────────────
  static Future<String> analyseEngagement({
    required String caption,
    required String platform,
    required String niche,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/content/analyse'),
      headers: _headers,
      body: jsonEncode({
        'caption': caption,
        'platform': platform,
        'niche': niche,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Analysis failed: ${response.statusCode}');
    }
  }
}
