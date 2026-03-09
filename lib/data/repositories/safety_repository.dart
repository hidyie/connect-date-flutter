import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SafetyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _blocksTable = 'blocks';
  static const String _reportsTable = 'reports';
  static const String _safetyCheckinsTable = 'safety_checkins';
  static const String _emergencyContactsTable = 'emergency_contacts';

  // Block a user so they no longer appear in the current user's feed
  Future<void> blockUser(String blockedId) async {
    try {
      final blockerId = _client.auth.currentUser?.id;
      if (blockerId == null) throw Exception('No authenticated user found');

      await _client.from(_blocksTable).insert({
        'blocker_id': blockerId,
        'blocked_id': blockedId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to block user $blockedId: $e');
    }
  }

  // Remove a block so the user can appear again
  Future<void> unblockUser(String blockedId) async {
    try {
      final blockerId = _client.auth.currentUser?.id;
      if (blockerId == null) throw Exception('No authenticated user found');

      await _client
          .from(_blocksTable)
          .delete()
          .eq('blocker_id', blockerId)
          .eq('blocked_id', blockedId);
    } catch (e) {
      throw Exception('Failed to unblock user $blockedId: $e');
    }
  }

  // Fetch the list of users blocked by the current user
  Future<List<Block>> getBlockedUsers() async {
    try {
      final blockerId = _client.auth.currentUser?.id;
      if (blockerId == null) throw Exception('No authenticated user found');

      final data = await _client
          .from(_blocksTable)
          .select()
          .eq('blocker_id', blockerId)
          .order('created_at', ascending: false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => Block.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch blocked users: $e');
    }
  }

  // Submit a report against another user with a reason and optional description
  Future<void> reportUser(
    String reportedId,
    String reason,
    String description,
  ) async {
    try {
      final reporterId = _client.auth.currentUser?.id;
      if (reporterId == null) throw Exception('No authenticated user found');

      await _client.from(_reportsTable).insert({
        'reporter_id': reporterId,
        'reported_id': reportedId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to report user $reportedId: $e');
    }
  }

  // Create a new safety check-in session (e.g. before a date)
  Future<SafetyCheckin> createSafetyCheckin(SafetyCheckin checkin) async {
    try {
      final data = await _client
          .from(_safetyCheckinsTable)
          .insert(checkin.toJson())
          .select()
          .single();

      return SafetyCheckin.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create safety check-in: $e');
    }
  }

  // Record a check-in confirmation to signal the user is safe
  Future<void> checkIn(String checkinId) async {
    try {
      await _client
          .from(_safetyCheckinsTable)
          .update({
            'last_checked_in_at': DateTime.now().toIso8601String(),
            'status': 'checked_in',
          })
          .eq('id', checkinId);
    } catch (e) {
      throw Exception('Failed to check in for session $checkinId: $e');
    }
  }

  // Fetch the current user's emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final data = await _client
          .from(_emergencyContactsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => EmergencyContact.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch emergency contacts: $e');
    }
  }

  // Add a new emergency contact for the current user
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      await _client.from(_emergencyContactsTable).insert(contact.toJson());
    } catch (e) {
      throw Exception('Failed to add emergency contact: $e');
    }
  }
}
