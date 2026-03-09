class Profile {
  final String id;
  final String userId;
  final String displayName;
  final int age;
  final String gender;
  final String? bio;
  final String? avatarUrl;
  final String city;
  final List<String> interests;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String lookingFor;
  final int minAge;
  final int maxAge;
  final bool onboardingComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.age,
    required this.gender,
    this.bio,
    this.avatarUrl,
    required this.city,
    required this.interests,
    required this.photos,
    this.latitude,
    this.longitude,
    required this.lookingFor,
    this.minAge = 18,
    this.maxAge = 50,
    required this.onboardingComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      city: json['city'] as String,
      interests: List<String>.from(json['interests'] as List? ?? []),
      photos: List<String>.from(json['photos'] as List? ?? []),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      lookingFor: json['looking_for'] as String,
      minAge: json['min_age'] as int? ?? 18,
      maxAge: json['max_age'] as int? ?? 50,
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'age': age,
      'gender': gender,
      'bio': bio,
      'avatar_url': avatarUrl,
      'city': city,
      'interests': interests,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
      'looking_for': lookingFor,
      'min_age': minAge,
      'max_age': maxAge,
      'onboarding_complete': onboardingComplete,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? displayName,
    int? age,
    String? gender,
    String? bio,
    String? avatarUrl,
    String? city,
    List<String>? interests,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? lookingFor,
    int? minAge,
    int? maxAge,
    bool? onboardingComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lookingFor: lookingFor ?? this.lookingFor,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Profile(id: $id, displayName: $displayName, age: $age)';
}
