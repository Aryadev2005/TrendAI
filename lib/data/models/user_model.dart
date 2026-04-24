class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? followerRange;
  final String? primaryPlatform;
  final List<String> niches;
  final bool isPro;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.followerRange,
    this.primaryPlatform,
    this.niches = const [],
    this.isPro = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? followerRange,
    String? primaryPlatform,
    List<String>? niches,
    bool? isPro,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      followerRange: followerRange ?? this.followerRange,
      primaryPlatform: primaryPlatform ?? this.primaryPlatform,
      niches: niches ?? this.niches,
      isPro: isPro ?? this.isPro,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      followerRange: map['followerRange'],
      primaryPlatform: map['primaryPlatform'],
      niches: List<String>.from(map['niches'] ?? []),
      isPro: map['isPro'] ?? false,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'followerRange': followerRange,
    'primaryPlatform': primaryPlatform,
    'niches': niches,
    'isPro': isPro,
    'createdAt': createdAt.toIso8601String(),
  };
}
