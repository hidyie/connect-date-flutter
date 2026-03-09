class PremiumSubscription {
  final String id;
  final String userId;
  final String plan;
  final bool unlimitedLikes;
  final bool unlimitedRewinds;
  final bool seeWhoLikesYou;
  final int boostCount;
  final int superLikeCount;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PremiumSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.unlimitedLikes,
    required this.unlimitedRewinds,
    required this.seeWhoLikesYou,
    required this.boostCount,
    required this.superLikeCount,
    required this.createdAt,
    this.expiresAt,
  });

  // plan: free | gold | platinum
  bool get isFree => plan == 'free';
  bool get isGold => plan == 'gold';
  bool get isPlatinum => plan == 'platinum';
  bool get isPremium => isGold || isPlatinum;

  bool get isActive {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  factory PremiumSubscription.fromJson(Map<String, dynamic> json) {
    return PremiumSubscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plan: json['plan'] as String,
      unlimitedLikes: json['unlimited_likes'] as bool? ?? false,
      unlimitedRewinds: json['unlimited_rewinds'] as bool? ?? false,
      seeWhoLikesYou: json['see_who_likes_you'] as bool? ?? false,
      boostCount: json['boost_count'] as int? ?? 0,
      superLikeCount: json['super_like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan,
      'unlimited_likes': unlimitedLikes,
      'unlimited_rewinds': unlimitedRewinds,
      'see_who_likes_you': seeWhoLikesYou,
      'boost_count': boostCount,
      'super_like_count': superLikeCount,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  PremiumSubscription copyWith({
    String? id,
    String? userId,
    String? plan,
    bool? unlimitedLikes,
    bool? unlimitedRewinds,
    bool? seeWhoLikesYou,
    int? boostCount,
    int? superLikeCount,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PremiumSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      unlimitedLikes: unlimitedLikes ?? this.unlimitedLikes,
      unlimitedRewinds: unlimitedRewinds ?? this.unlimitedRewinds,
      seeWhoLikesYou: seeWhoLikesYou ?? this.seeWhoLikesYou,
      boostCount: boostCount ?? this.boostCount,
      superLikeCount: superLikeCount ?? this.superLikeCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumSubscription &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PremiumSubscription(id: $id, userId: $userId, plan: $plan, isActive: $isActive)';
}
