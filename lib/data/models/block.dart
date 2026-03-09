class Block {
  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  const Block({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as String,
      blockerId: json['blocker_id'] as String,
      blockedId: json['blocked_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blocker_id': blockerId,
      'blocked_id': blockedId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Block copyWith({
    String? id,
    String? blockerId,
    String? blockedId,
    DateTime? createdAt,
  }) {
    return Block(
      id: id ?? this.id,
      blockerId: blockerId ?? this.blockerId,
      blockedId: blockedId ?? this.blockedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Block && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Block(id: $id, blockerId: $blockerId, blockedId: $blockedId)';
}
