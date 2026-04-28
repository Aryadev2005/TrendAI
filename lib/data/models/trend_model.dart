class TrendModel {
  final String id;
  final String title;
  final String platform;
  final String stat;
  final String badge;
  final String aiTip;
  final int scorePercentage;
  final String? niche;
  final DateTime detectedAt;
  final bool isPersonalized;

  const TrendModel({
    required this.id,
    required this.title,
    required this.platform,
    required this.stat,
    required this.badge,
    required this.aiTip,
    required this.scorePercentage,
    this.niche,
    required this.detectedAt,
    this.isPersonalized = false,
  });

  factory TrendModel.fromMap(Map<String, dynamic> map) {
    return TrendModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      platform: map['platform'] ?? '',
      stat: map['stat'] ?? '',
      badge: map['badge'] ?? 'NEW',
      aiTip: map['aiTip'] ?? '',
      scorePercentage: (map['scorePercentage'] as num?)?.toInt() ?? 0,
      niche: map['niche'],
      detectedAt: DateTime.parse(map['detectedAt'] ?? map['createdAt'] ?? DateTime.now().toIso8601String()),
      isPersonalized: map['isPersonalized'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'platform': platform,
    'stat': stat,
    'badge': badge,
    'aiTip': aiTip,
    'scorePercentage': scorePercentage,
    'niche': niche,
    'detectedAt': detectedAt.toIso8601String(),
    'isPersonalized': isPersonalized,
  };
}