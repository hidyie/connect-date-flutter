import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = 'profiles';
  static const String _avatarsBucket = 'avatars';
  static const String _photosBucket = 'photos';

  // Fetch a profile by its user ID
  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch profile for user $userId: $e');
    }
  }

  // Fetch the currently authenticated user's profile
  Future<Profile?> getMyProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');
      return getProfile(userId);
    } catch (e) {
      throw Exception('Failed to fetch my profile: $e');
    }
  }

  // Create or update a profile record
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final data = await _client
          .from(_table)
          .upsert(profile.toJson())
          .select()
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload avatar image and return its public URL
  Future<String> uploadAvatar(File file) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final fileExt = file.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';

      await _client.storage.from(_avatarsBucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final url = _client.storage.from(_avatarsBucket).getPublicUrl(filePath);
      return url;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  // Upload a profile photo and return its public URL
  Future<String> uploadPhoto(File file) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = file.path.split('.').last;
      final filePath = '$userId/photo_$timestamp.$fileExt';

      await _client.storage.from(_photosBucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      final url = _client.storage.from(_photosBucket).getPublicUrl(filePath);
      return url;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Fetch nearby profiles using the get_nearby_profiles RPC function
  Future<List<Profile>> getNearbyProfiles({
    required double lat,
    required double lng,
    required double maxDistance,
    required int ageMin,
    required int ageMax,
    required String genderFilter,
    required List<String> excludeIds,
  }) async {
    try {
      final response = await _client.rpc(
        'get_nearby_profiles',
        params: {
          'lat': lat,
          'lng': lng,
          'max_distance': maxDistance,
          'age_min': ageMin,
          'age_max': ageMax,
          'gender_filter': genderFilter,
          'exclude_ids': excludeIds,
        },
      );

      final List<dynamic> rows = response as List<dynamic>;
      return rows
          .map((row) => Profile.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby profiles: $e');
    }
  }
}
