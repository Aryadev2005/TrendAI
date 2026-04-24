class ContentModel {
  final String id;
  final String trendId;
  final String hook;
  final String caption;
  final List<String> hashtags;
  final String bestTimeToPost;
  final String platform;
  final DateTime generatedAt;

  const ContentModel({
    required this.id,
    required this.trendId,
    required this.hook,
    required this.caption,
    required this.hashtags,
    required this.bestTimeToPost,
    required this.platform,
    required this.generatedAt,
  });

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] ?? '',
      trendId: map['trendId'] ?? '',
      hook: map['hook'] ?? '',
      caption: map['caption'] ?? '',
      hashtags: List<String>.from(map['hashtags'] ?? []),
      bestTimeToPost: map['bestTimeToPost'] ?? '',
      platform: map['platform'] ?? '',
      generatedAt: DateTime.parse(map['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'trendId': trendId,
    'hook': hook,
    'caption': caption,
    'hashtags': hashtags,
    'bestTimeToPost': bestTimeToPost,
    'platform': platform,
    'generatedAt': generatedAt.toIso8601String(),
  };
}