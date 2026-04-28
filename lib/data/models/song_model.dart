class SongModel {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String useCount;
  final String growthPercent;
  final String badge;
  final String platform;
  final String aiTip;
  final String lifecycle; // rising | peak | declining
  final String signal; // PostNow | PostSoon | Avoid
  final int bpm;
  final int durationSecs;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.useCount,
    required this.growthPercent,
    required this.badge,
    required this.platform,
    required this.aiTip,
    this.lifecycle = 'peak',
    this.signal = 'PostNow',
    this.bpm = 120,
    this.durationSecs = 30,
  });

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      genre: map['genre'] ?? '',
      useCount: map['useCount']?.toString() ?? '',
      growthPercent: map['growthPercent']?.toString() ?? '',
      badge: map['badge'] ?? 'NEW',
      platform: map['platform'] ?? '',
      aiTip: map['aiTip'] ?? '',
      lifecycle: map['lifecycle'] ?? 'peak',
      signal: map['signal'] ?? 'PostNow',
      bpm: (map['bpm'] as num?)?.toInt() ?? 120,
      durationSecs: (map['durationSecs'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'artist': artist,
    'genre': genre,
    'useCount': useCount,
    'growthPercent': growthPercent,
    'badge': badge,
    'platform': platform,
    'aiTip': aiTip,
    'lifecycle': lifecycle,
    'signal': signal,
    'bpm': bpm,
    'durationSecs': durationSecs,
  };
}
