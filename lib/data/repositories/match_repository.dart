import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class MatchRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = 'matches';

  // Create a new like or super-like towards a target user
  Future<Match> createMatch(
    String targetUserId, {
    bool isSuperLike = false,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception('No authenticated user found');

      final data = await _client
          .from(_table)
          .insert({
            'user_id': currentUserId,
            'target_user_id': targetUserId,
            'is_super_like': isSuperLike,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Match.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  // Fetch all confirmed mutual matches for a user
  Future<List<Match>> getMatches(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .or('user_id.eq.$userId,target_user_id.eq.$userId')
          .eq('status', 'matched')
          .order('created_at', ascending: false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => Match.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch matches: $e');
    }
  }

  // Fetch matches that are still in pending status for a user
  Future<List<Match>> getPendingMatches(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => Match.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending matches: $e');
    }
  }

  // Fetch users who have liked the given user (likes received)
  Future<List<Match>> getWhoLikesMe(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('target_user_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => Match.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch who likes me: $e');
    }
  }

  // Update the status of a match (e.g. 'matched', 'rejected', 'blocked')
  Future<void> updateMatchStatus(String matchId, String status) async {
    try {
      await _client
          .from(_table)
          .update({'status': status})
          .eq('id', matchId);
    } catch (e) {
      throw Exception('Failed to update match status: $e');
    }
  }

  // Count how many super-likes the user has sent today
  Future<int> getSuperLikeCountToday(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final data = await _client
          .from(_table)
          .select('id')
          .eq('user_id', userId)
          .eq('is_super_like', true)
          .gte('created_at', startOfDay.toIso8601String());

      final List<dynamic> rows = data as List<dynamic>;
      return rows.length;
    } catch (e) {
      throw Exception('Failed to fetch super like count: $e');
    }
  }
}
