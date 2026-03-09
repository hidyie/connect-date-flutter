import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _notificationsTable = 'notifications';
  static const String _fcmTokensTable = 'fcm_tokens';

  // Fetch all notifications for a user, newest first
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final data = await _client
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => AppNotification.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications for user $userId: $e');
    }
  }

  // Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from(_notificationsTable)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Count unread notifications for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from(_notificationsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows.length;
    } catch (e) {
      throw Exception(
          'Failed to fetch unread notification count for user $userId: $e');
    }
  }

  // Store or update the FCM device token for push notification delivery
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _client.from(_fcmTokensTable).upsert({
        'user_id': userId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  // Subscribe to real-time new notifications for a user
  Stream<AppNotification> subscribeToNotifications(String userId) {
    return _client
        .from(_notificationsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.first)
        .where((row) => row.isNotEmpty)
        .map((row) => AppNotification.fromJson(row));
  }
}
