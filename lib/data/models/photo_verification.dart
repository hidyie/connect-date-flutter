class PhotoVerification {
  final String id;
  final String userId;
  final String selfieUrl;
  final String status;
  final DateTime? verifiedAt;
  final double? aiConfidence;
  final DateTime createdAt;

  const PhotoVerification({
    required this.id,
    required this.userId,
    required this.selfieUrl,
    required this.status,
    this.verifiedAt,
    this.aiConfidence,
    required this.createdAt,
  });

  // status: pending | verified | rejected
  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';

  factory PhotoVerification.fromJson(Map<String, dynamic> json) {
    return PhotoVerification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      selfieUrl: json['selfie_url'] as String,
      status: json['status'] as String,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'selfie_url': selfieUrl,
      'status': status,
      'verified_at': verifiedAt?.toIso8601String(),
      'ai_confidence': aiConfidence,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PhotoVerification copyWith({
    String? id,
    String? userId,
    String? selfieUrl,
    String? status,
    DateTime? verifiedAt,
    double? aiConfidence,
    DateTime? createdAt,
  }) {
    return PhotoVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoVerification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PhotoVerification(id: $id, userId: $userId, status: $status)';
}
