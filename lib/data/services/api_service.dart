import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trend_model.dart';
import '../models/song_model.dart';

class ApiService {
  static const _claudeApiUrl = 'https://api.anthropic.com/v1/messages';
  static const _apiKey = 'YOUR_CLAUDE_API_KEY_HERE'; // Replace before build
  static const _model = 'claude-sonnet-4-20250514';
  static const _anthropicVersion = '2023-06-01';

  // ─── Headers ──────────────────────────────────────────────────────────────
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
    'anthropic-version': _anthropicVersion,
  };

  // ─── Generate Content ─────────────────────────────────────────────────────
  static Future<String> generateContent({
    required String trendTitle,
    required String niche,
    required String platform,
    required String followerRange,
  }) async {
    final prompt = '''
You are an expert social media content strategist for Indian influencers.

A $niche influencer with $followerRange followers wants to create content for this trending topic:
"$trendTitle" on $platform

Respond ONLY with a JSON object, no markdown, no extra text:
{
  "hook": "attention-grabbing first line (use ₹ for prices, relatable India context)",
  "caption": "engaging caption 2-3 sentences with emojis",
  "hashtags": ["#tag1", "#tag2", "#tag3", "#tag4", "#tag5"],
  "bestTimeToPost": "best time in IST e.g. Today · 7:30 PM IST"
}
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: _headers,
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1000,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
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
    final prompt = '''
You are a social media trend analyst specialising in Indian content creators.

Generate 6 trending content ideas for a $niche creator with $followerRange followers on $platform.

Respond ONLY with a JSON array, no markdown:
[
  {
    "id": "unique_id",
    "title": "trend title",
    "platform": "platform name",
    "stat": "engagement stat e.g. 2.4M views",
    "badge": "HOT or RISING or NEW",
    "aiTip": "actionable tip for the creator in 1 sentence",
    "isPersonalized": true
  }
]

Focus on India-relevant trends. Use ₹ for prices. Reference Indian platforms, festivals, and culture.
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: _headers,
      body: jsonEncode({
        'model': _model,
        'max_tokens': 2000,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Trend fetch failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final raw = (data['content'][0]['text'] as String)
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    final List<dynamic> list = jsonDecode(raw);
    return list.map((item) => TrendModel.fromMap({
      ...item as Map<String, dynamic>,
      'detectedAt': DateTime.now().toIso8601String(),
    })).toList();
  }

  // ─── Get Top Songs ────────────────────────────────────────────────────────
  static Future<List<SongModel>> getTopSongs({
    required String niche,
    required String platform,
    required String followerRange,
  }) async {
    final prompt = '''
You are a music trend analyst specialising in Indian content creators.

Generate 7 trending songs for a $niche creator with $followerRange followers to use on $platform.

Respond ONLY with a JSON array, no markdown:
[
  {
    "id": "unique_id",
    "title": "song title",
    "artist": "artist name",
    "genre": "genre e.g. Bollywood / Indie / Hip-Hop",
    "useCount": "e.g. 1.2M uses",
    "growthPercent": "e.g. +180%",
    "badge": "HOT or RISING or NEW",
    "platform": "platform name",
    "aiTip": "one actionable sentence for the creator",
    "bpm": 120,
    "durationSecs": 30
  }
]

Focus on India-relevant music. Include Bollywood, Indie, Punjabi, and Desi Hip-Hop tracks.
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: _headers,
      body: jsonEncode({
        'model': _model,
        'max_tokens': 2000,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Song fetch failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final raw = (data['content'][0]['text'] as String)
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    final List<dynamic> list = jsonDecode(raw);
    return list.map((item) => SongModel.fromMap(item as Map<String, dynamic>)).toList();
  }

  // ─── Analyse engagement potential ─────────────────────────────────────────
  static Future<String> analyseEngagement({
    required String caption,
    required String platform,
    required String niche,
  }) async {
    final prompt = '''
Rate this social media caption for a $niche creator on $platform.
Caption: "$caption"

Respond ONLY with JSON:
{
  "score": 85,
  "verdict": "one word: Excellent / Good / Average / Weak",
  "tip": "one improvement tip"
}
''';

    final response = await http.post(
      Uri.parse(_claudeApiUrl),
      headers: _headers,
      body: jsonEncode({
        'model': _model,
        'max_tokens': 300,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    } else {
      throw Exception('Analysis failed: ${response.statusCode}');
    }
  }
}
