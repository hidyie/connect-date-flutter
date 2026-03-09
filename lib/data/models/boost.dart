class Boost {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Boost({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isActive => DateTime.now().isBefore(expiresAt);

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  factory Boost.fromJson(Map<String, dynamic> json) {
    return Boost(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  Boost copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Boost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Boost && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Boost(id: $id, userId: $userId, isActive: $isActive, expiresAt: $expiresAt)';
}
