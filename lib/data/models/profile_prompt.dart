class ProfilePrompt {
  final String id;
  final String userId;
  final String promptQuestion;
  final String promptAnswer;
  final int displayOrder;
  final DateTime createdAt;

  const ProfilePrompt({
    required this.id,
    required this.userId,
    required this.promptQuestion,
    required this.promptAnswer,
    required this.displayOrder,
    required this.createdAt,
  });

  factory ProfilePrompt.fromJson(Map<String, dynamic> json) {
    return ProfilePrompt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      promptQuestion: json['prompt_question'] as String,
      promptAnswer: json['prompt_answer'] as String,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'prompt_question': promptQuestion,
      'prompt_answer': promptAnswer,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProfilePrompt copyWith({
    String? id,
    String? userId,
    String? promptQuestion,
    String? promptAnswer,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return ProfilePrompt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      promptQuestion: promptQuestion ?? this.promptQuestion,
      promptAnswer: promptAnswer ?? this.promptAnswer,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfilePrompt &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProfilePrompt(id: $id, userId: $userId, displayOrder: $displayOrder)';
}
