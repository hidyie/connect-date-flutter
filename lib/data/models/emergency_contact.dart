class EmergencyContact {
  final String id;
  final String userId;
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? telegramChatId;
  final DateTime createdAt;

  const EmergencyContact({
    required this.id,
    required this.userId,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.telegramChatId,
    required this.createdAt,
  });

  bool get hasTelegram =>
      telegramChatId != null && telegramChatId!.isNotEmpty;

  bool get hasEmail => contactEmail != null && contactEmail!.isNotEmpty;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      contactName: json['contact_name'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String?,
      telegramChatId: json['telegram_chat_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'telegram_chat_id': telegramChatId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? userId,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? telegramChatId,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContact &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'EmergencyContact(id: $id, userId: $userId, contactName: $contactName)';
}
