// lib/data/models/profile_model.dart

class ARIAIntelligence {
  final int    healthScore;
  final String healthLabel;
  final String growthStage;
  final String growthStageLabel;
  final List<String> strengths;
  final List<String> gaps;
  final String topOpportunity;
  final int    monetisationReadiness;
  final String estimatedMonthlyEarning;
  final String nextMilestone;
  final String nextMilestoneAction;
  final String ariaVerdict;

  const ARIAIntelligence({
    required this.healthScore,
    required this.healthLabel,
    required this.growthStage,
    required this.growthStageLabel,
    required this.strengths,
    required this.gaps,
    required this.topOpportunity,
    required this.monetisationReadiness,
    required this.estimatedMonthlyEarning,
    required this.nextMilestone,
    required this.nextMilestoneAction,
    required this.ariaVerdict,
  });

  factory ARIAIntelligence.fromJson(Map<String, dynamic> j) => ARIAIntelligence(
    healthScore:             j['healthScore']             ?? 50,
    healthLabel:             j['healthLabel']             ?? 'Growing',
    growthStage:             j['growthStage']             ?? 'DISCOVERY',
    growthStageLabel:        j['growthStageLabel']        ?? 'Building Audience',
    strengths:               List<String>.from(j['strengths'] ?? []),
    gaps:                    List<String>.from(j['gaps']      ?? []),
    topOpportunity:          j['topOpportunity']          ?? '',
    monetisationReadiness:   j['monetisationReadiness']   ?? 0,
    estimatedMonthlyEarning: j['estimatedMonthlyEarning'] ?? '₹0',
    nextMilestone:           j['nextMilestone']           ?? '',
    nextMilestoneAction:     j['nextMilestoneAction']     ?? '',
    ariaVerdict:             j['ariaVerdict']             ?? '',
  );
}

class TopVideo {
  final String title;
  final String videoId;
  final String thumbnail;
  final int    views;
  final int    likes;
  final int    comments;

  const TopVideo({
    required this.title,
    required this.videoId,
    required this.thumbnail,
    required this.views,
    required this.likes,
    required this.comments,
  });

  factory TopVideo.fromJson(Map<String, dynamic> j) => TopVideo(
    title:     j['title']     ?? '',
    videoId:   j['videoId']   ?? '',
    thumbnail: j['thumbnail'] ?? '',
    views:     j['views']     ?? 0,
    likes:     j['likes']     ?? 0,
    comments:  j['comments']  ?? 0,
  );

  double get engagementRate =>
    views > 0 ? ((likes + comments) / views * 100) : 0;
}

class CreatorAnalytics {
  final String platform;
  final String handle;
  final int    followers;
  final String engagementRate;
  final String followerRange;
  final bool   fromCache;
  final String dataSource;
  final ARIAIntelligence? ariaIntelligence;

  // YouTube-specific
  final int?   totalViews;
  final int?   videoCount;
  final int?   avgViewsPerVideo;
  final String? uploadFrequency;
  final String? estimatedCPM;
  final String? estimatedMonthlyRevenue;
  final List<TopVideo> topVideos;
  final String? topVideoTitle;
  final int?   topVideoViews;
  final String? channelName;

  // Instagram-specific
  final List<String> topHashtags;
  final List<String> topPosts;
  final int?   postsAnalyzed;
  final String? postingFrequency;
  final int?   avgLikes;
  final int?   avgComments;

  const CreatorAnalytics({
    required this.platform,
    required this.handle,
    required this.followers,
    required this.engagementRate,
    required this.followerRange,
    required this.fromCache,
    required this.dataSource,
    this.ariaIntelligence,
    this.totalViews,
    this.videoCount,
    this.avgViewsPerVideo,
    this.uploadFrequency,
    this.estimatedCPM,
    this.estimatedMonthlyRevenue,
    this.topVideos = const [],
    this.topVideoTitle,
    this.topVideoViews,
    this.channelName,
    this.topHashtags = const [],
    this.topPosts    = const [],
    this.postsAnalyzed,
    this.postingFrequency,
    this.avgLikes,
    this.avgComments,
  });

  bool get isYouTube   => platform == 'youtube';
  bool get isInstagram => platform == 'instagram';

  factory CreatorAnalytics.fromJson(Map<String, dynamic> j) {
    final intel = j['ariaIntelligence'] as Map<String, dynamic>?;
    return CreatorAnalytics(
      platform:       j['platform']       ?? 'instagram',
      handle:         j['handle']         ?? '',
      followers:      j['followers']      ?? 0,
      engagementRate: j['engagementRate']?.toString() ?? '0',
      followerRange:  j['followerRange']  ?? '1K–10K',
      fromCache:      j['fromCache']      ?? false,
      dataSource:     j['dataSource']     ?? '',
      ariaIntelligence: intel != null ? ARIAIntelligence.fromJson(intel) : null,
      // YouTube
      totalViews:          j['totalViews'],
      videoCount:          j['videoCount'],
      avgViewsPerVideo:    j['avgViewsPerVideo'],
      uploadFrequency:     j['uploadFrequency'],
      estimatedCPM:        j['estimatedCPM'],
      estimatedMonthlyRevenue: j['estimatedMonthlyRevenue'],
      topVideos: (j['topVideos'] as List? ?? [])
          .map((v) => TopVideo.fromJson(v)).toList(),
      topVideoTitle: j['topVideoTitle'],
      topVideoViews: j['topVideoViews'],
      channelName:   j['channelName'],
      // Instagram
      topHashtags:      List<String>.from(j['topHashtags'] ?? []),
      topPosts:         List<String>.from(j['topPosts']    ?? []),
      postsAnalyzed:    j['postsAnalyzed'],
      postingFrequency: j['postingFrequency'],
      avgLikes:         j['avgLikes'],
      avgComments:      j['avgComments'],
    );
  }
}

class CreatorProfile {
  final String id;
  final String name;
  final String email;
  final String? instagramHandle;
  final String? youtubeHandle;
  final String primaryPlatform;
  final String archetype;
  final List<String> niches;
  final String followerRange;
  final String? subscriptionPlan;
  final bool isOnboarded;
  final int memoryCount;

  const CreatorProfile({
    required this.id,
    required this.name,
    required this.email,
    this.instagramHandle,
    this.youtubeHandle,
    required this.primaryPlatform,
    required this.archetype,
    required this.niches,
    required this.followerRange,
    this.subscriptionPlan,
    required this.isOnboarded,
    required this.memoryCount,
  });

  String get activeHandle => primaryPlatform == 'youtube'
      ? (youtubeHandle ?? '') : (instagramHandle ?? '');

  bool get isPro => subscriptionPlan == 'pro' ||
      subscriptionPlan == 'brand' || subscriptionPlan == 'agency';

  factory CreatorProfile.fromJson(Map<String, dynamic> j) => CreatorProfile(
    id:               j['id']               ?? '',
    name:             j['name']             ?? '',
    email:            j['email']            ?? '',
    instagramHandle:  j['instagram_handle'],
    youtubeHandle:    j['youtube_handle'],
    primaryPlatform:  j['primary_platform'] ?? 'instagram',
    archetype:        j['archetype']        ?? 'EDUCATOR',
    niches:           List<String>.from(j['niches'] ?? ['general']),
    followerRange:    j['follower_range']   ?? '1K–10K',
    subscriptionPlan: j['subscription_plan'],
    isOnboarded:      j['isOnboarded']      ?? false,
    memoryCount:      j['memoryCount']      ?? 0,
  );
}
