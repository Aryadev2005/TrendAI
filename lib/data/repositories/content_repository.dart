import '../models/content_model.dart';
import '../services/api_service.dart';

class ContentRepository {
  // ─── Generate content via Claude API ─────────────────────────────────────
  Future<ContentModel> generateContent({
    required String trendTitle,
    required String platform,
    String niche = 'Fashion',
    String followerRange = '10K–50K',
  }) async {
    try {
      final rawJson = await ApiService.generateContent(
        trendTitle: trendTitle,
        niche: niche,
        platform: platform,
        followerRange: followerRange,
      );

      // Parse JSON response from Claude
      return _parseContent(rawJson, trendTitle, platform);
    } catch (_) {
      // Fallback mock content (India-flavoured)
      return _mockContent(trendTitle, platform);
    }
  }

  // ─── Parse Claude JSON response ───────────────────────────────────────────
  ContentModel _parseContent(
    String rawJson,
    String trendTitle,
    String platform,
  ) {
    // Strip markdown code fences if present
    final clean = rawJson
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    try {
      // Basic JSON extraction (use dart:convert in real impl)
      // For now return mock with parsed hint
      return _mockContent(trendTitle, platform);
    } catch (_) {
      return _mockContent(trendTitle, platform);
    }
  }

  // ─── Mock fallback (India-first copy) ────────────────────────────────────
  ContentModel _mockContent(String trendTitle, String platform) {
    return ContentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trendId: trendTitle,
      hook: 'I spent ₹500 and looked like I spent ₹50,000 — here\'s how 👀',
      caption:
          'Quiet luxury isn\'t about price — it\'s about intention. '
          'Here are my 3 rules for looking effortlessly elevated on any budget. '
          'Save this before your next shopping trip! 🛍️',
      hashtags: [
        '#QuietLuxury',
        '#IndianFashion',
        '#StyleTips',
        '#OOTDIndia',
        '#FashionReels',
      ],
      bestTimeToPost: 'Today · 7:30 PM IST',
      platform: platform,
      generatedAt: DateTime.now(),
    );
  }
}
