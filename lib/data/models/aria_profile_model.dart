// lib/data/models/aria_profile_model.dart

class ContentInsights {
  final String bestFormat;
  final String postingFrequency;
  final String bestTime;
  final String audienceAge;
  final String audienceGender;
  final String topCity;

  const ContentInsights({
    required this.bestFormat,
    required this.postingFrequency,
    required this.bestTime,
    required this.audienceAge,
    required this.audienceGender,
    required this.topCity,
  });

  factory ContentInsights.fromJson(Map<String, dynamic> j) => ContentInsights(
    bestFormat:       j['bestFormat']       ?? 'Reels',
    postingFrequency: j['postingFrequency'] ?? '3x/week',
    bestTime:         j['bestTime']         ?? '7:30 PM IST',
    audienceAge:      j['audienceAge']      ?? '18-35',
    audienceGender:   j['audienceGender']   ?? 'Mixed',
    topCity:          j['topCity']          ?? 'India',
  );
}

class ARIAProfileAnalysis {
  final String archetype;
  final String archetypeLabel;
  final String archetypeEmoji;
  final int archetypeConfidence;
  final List<String> detectedNiches;
  final String followerRange;
  final int healthScore;
  final String growthStage;
  final List<String> strengths;
  final List<String> gaps;
  final String topOpportunity;
  final ContentInsights contentInsights;
  final int monetisationReadiness;
  final String estimatedMonthlyEarning;
  final String ariaMessage;
  final List<String> brandCategories;

  // Scrape metadata
  final int? followers;
  final String? engagementRate;
  final int? postsAnalyzed;
  final String? scrapeError;

  const ARIAProfileAnalysis({
    required this.archetype,
    required this.archetypeLabel,
    required this.archetypeEmoji,
    required this.archetypeConfidence,
    required this.detectedNiches,
    required this.followerRange,
    required this.healthScore,
    required this.growthStage,
    required this.strengths,
    required this.gaps,
    required this.topOpportunity,
    required this.contentInsights,
    required this.monetisationReadiness,
    required this.estimatedMonthlyEarning,
    required this.ariaMessage,
    required this.brandCategories,
    this.followers,
    this.engagementRate,
    this.postsAnalyzed,
    this.scrapeError,
  });

  factory ARIAProfileAnalysis.fromJson(Map<String, dynamic> json) {
    final analysis   = json['ariaAnalysis'] as Map<String, dynamic>? ?? json;
    final scraped    = json['scrapedData']  as Map<String, dynamic>?;

    return ARIAProfileAnalysis(
      archetype:              analysis['archetype']              ?? 'EDUCATOR',
      archetypeLabel:         analysis['archetypeLabel']         ?? 'The Creator',
      archetypeEmoji:         analysis['archetypeEmoji']         ?? '🎯',
      archetypeConfidence:    analysis['archetypeConfidence']    ?? 60,
      detectedNiches:         List<String>.from(analysis['detectedNiches'] ?? ['general']),
      followerRange:          analysis['followerRange']          ?? '1K–10K',
      healthScore:            analysis['healthScore']            ?? 50,
      growthStage:            analysis['growthStage']            ?? 'DISCOVERY',
      strengths:              List<String>.from(analysis['strengths'] ?? []),
      gaps:                   List<String>.from(analysis['gaps']      ?? []),
      topOpportunity:         analysis['topOpportunity']         ?? '',
      contentInsights: ContentInsights.fromJson(
        analysis['contentInsights'] as Map<String, dynamic>? ?? {},
      ),
      monetisationReadiness:  analysis['monetisationReadiness'] ?? 30,
      estimatedMonthlyEarning: analysis['estimatedMonthlyEarning'] ?? '₹0',
      ariaMessage:            analysis['ariaMessage']            ?? '',
      brandCategories:        List<String>.from(analysis['brandCategories'] ?? []),
      followers:              scraped?['followers'] as int?,
      engagementRate:         scraped?['engagementRate']?.toString(),
      postsAnalyzed:          scraped?['postsAnalyzed'] as int?,
      scrapeError:            json['scrapeError'] as String?,
    );
  }

  // Color based on health score
  String get healthLabel =>
    healthScore >= 80 ? 'Excellent' :
    healthScore >= 60 ? 'Good' :
    healthScore >= 40 ? 'Growing' : 'Early Stage';
}
