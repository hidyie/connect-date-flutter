class MusicPreference {
  final String id;
  final String userId;
  final bool spotifyConnected;
  final List<String> topArtists;
  final List<String> topTracks;
  final List<String> favoriteGenres;
  final String? spotifyDisplayName;
  final DateTime updatedAt;

  const MusicPreference({
    required this.id,
    required this.userId,
    required this.spotifyConnected,
    required this.topArtists,
    required this.topTracks,
    required this.favoriteGenres,
    this.spotifyDisplayName,
    required this.updatedAt,
  });

  factory MusicPreference.fromJson(Map<String, dynamic> json) {
    return MusicPreference(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spotifyConnected: json['spotify_connected'] as bool? ?? false,
      topArtists: List<String>.from(json['top_artists'] as List? ?? []),
      topTracks: List<String>.from(json['top_tracks'] as List? ?? []),
      favoriteGenres: List<String>.from(json['favorite_genres'] as List? ?? []),
      spotifyDisplayName: json['spotify_display_name'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'spotify_connected': spotifyConnected,
      'top_artists': topArtists,
      'top_tracks': topTracks,
      'favorite_genres': favoriteGenres,
      'spotify_display_name': spotifyDisplayName,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MusicPreference copyWith({
    String? id,
    String? userId,
    bool? spotifyConnected,
    List<String>? topArtists,
    List<String>? topTracks,
    List<String>? favoriteGenres,
    String? spotifyDisplayName,
    DateTime? updatedAt,
  }) {
    return MusicPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
      topArtists: topArtists ?? this.topArtists,
      topTracks: topTracks ?? this.topTracks,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      spotifyDisplayName: spotifyDisplayName ?? this.spotifyDisplayName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicPreference &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MusicPreference(id: $id, userId: $userId, spotifyConnected: $spotifyConnected)';
}
