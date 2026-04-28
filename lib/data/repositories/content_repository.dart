import '../models/content_model.dart';
import '../services/content_service.dart';

class ContentRepository {
  final ContentService _contentService = ContentService();

  Future<ContentModel> generateContent({
    required String trendTitle,
    required String platform,
    String niche = 'fashion',
    String? songTitle,
    String tone = 'casual',
    String language = 'hinglish',
  }) async {
    try {
      return await _contentService.generateContent(
        trendTitle: trendTitle,
        platform: platform,
        niche: niche,
        songTitle: songTitle,
        tone: tone,
        language: language,
      );
    } catch (_) {
      // Fallback to mock content
      return _mockContent(trendTitle, platform);
    }
  }

  ContentModel _mockContent(String trendTitle, String platform) {
    return ContentModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      trendId: 'trend_1',
      hook: 'POV: You just discovered the $trendTitle trend that\'s breaking the internet ✨',
      caption: 'If you\'re not using $trendTitle yet, you\'re missing out! 🔥\n\nThis trend is perfect for $platform creators right now. The engagement is INSANE. \n\n#$trendTitle #TrendAlert #CreatorTips',
      hashtags: [trendTitle, 'Trending', 'CreatorTips', 'FYP', 'Viral'],
      bestTimeToPost: '7 PM - 9 PM IST',
      platform: platform,
      contentFormat: 'Reel',
      thumbnailText: trendTitle,
      cta: 'Try this trend now!',
      generatedAt: DateTime.now(),
    );
  }
}
