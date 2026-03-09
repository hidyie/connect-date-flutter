class Report {
  final String id;
  final String reporterId;
  final String reportedId;
  final String reason;
  final String? description;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  // reason: spam | harassment | fake_profile | inappropriate_content | other
  bool get isSpam => reason == 'spam';
  bool get isHarassment => reason == 'harassment';
  bool get isFakeProfile => reason == 'fake_profile';
  bool get isInappropriateContent => reason == 'inappropriate_content';
  bool get isOther => reason == 'other';

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportedId: json['reported_id'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_id': reportedId,
      'reason': reason,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? reportedId,
    String? reason,
    String? description,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedId: reportedId ?? this.reportedId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Report && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Report(id: $id, reporterId: $reporterId, reportedId: $reportedId, reason: $reason)';
}
