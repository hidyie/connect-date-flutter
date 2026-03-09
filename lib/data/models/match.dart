class Match {
  final String id;
  final String userId;
  final String targetUserId;
  final String status;
  final bool isSuperLike;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.status,
    this.isSuperLike = false,
    required this.createdAt,
  });

  // status: pending | matched | rejected
  bool get isPending => status == 'pending';
  bool get isMatched => status == 'matched';
  bool get isRejected => status == 'rejected';

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      status: json['status'] as String,
      isSuperLike: json['is_super_like'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'status': status,
      'is_super_like': isSuperLike,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Match copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    String? status,
    bool? isSuperLike,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      status: status ?? this.status,
      isSuperLike: isSuperLike ?? this.isSuperLike,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Match(id: $id, userId: $userId, targetUserId: $targetUserId, status: $status)';
}
