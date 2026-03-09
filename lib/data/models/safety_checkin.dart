class SafetyCheckin {
  final String id;
  final String userId;
  final String? matchId;
  final String partnerName;
  final String? meetingLocation;
  final int timerMinutes;
  final DateTime startedAt;
  final DateTime expiresAt;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final bool alertSent;

  const SafetyCheckin({
    required this.id,
    required this.userId,
    this.matchId,
    required this.partnerName,
    this.meetingLocation,
    this.timerMinutes = 60,
    required this.startedAt,
    required this.expiresAt,
    required this.checkedIn,
    this.checkedInAt,
    required this.alertSent,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired && !checkedIn;

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  factory SafetyCheckin.fromJson(Map<String, dynamic> json) {
    return SafetyCheckin(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      matchId: json['match_id'] as String?,
      partnerName: json['partner_name'] as String,
      meetingLocation: json['meeting_location'] as String?,
      timerMinutes: json['timer_minutes'] as int? ?? 60,
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      checkedIn: json['checked_in'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      alertSent: json['alert_sent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'match_id': matchId,
      'partner_name': partnerName,
      'meeting_location': meetingLocation,
      'timer_minutes': timerMinutes,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'checked_in': checkedIn,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'alert_sent': alertSent,
    };
  }

  SafetyCheckin copyWith({
    String? id,
    String? userId,
    String? matchId,
    String? partnerName,
    String? meetingLocation,
    int? timerMinutes,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool? checkedIn,
    DateTime? checkedInAt,
    bool? alertSent,
  }) {
    return SafetyCheckin(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchId: matchId ?? this.matchId,
      partnerName: partnerName ?? this.partnerName,
      meetingLocation: meetingLocation ?? this.meetingLocation,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      alertSent: alertSent ?? this.alertSent,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyCheckin &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SafetyCheckin(id: $id, userId: $userId, partnerName: $partnerName, checkedIn: $checkedIn)';
}
