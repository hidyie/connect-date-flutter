import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class MessageRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = 'messages';
  static const String _chatImagesBucket = 'chat-images';
  static const String _voiceMessagesBucket = 'voice-messages';

  // Fetch all messages for a given match, ordered chronologically
  Future<List<Message>> getMessages(String matchId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('match_id', matchId)
          .order('created_at', ascending: true);

      final List<dynamic> rows = data as List<dynamic>;
      return rows
          .map((row) => Message.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch messages for match $matchId: $e');
    }
  }

  // Send a text, image, or voice message in a match conversation
  Future<Message> sendMessage(
    String matchId,
    String content, {
    String? imageUrl,
    String? audioUrl,
  }) async {
    try {
      final senderId = _client.auth.currentUser?.id;
      if (senderId == null) throw Exception('No authenticated user found');

      final data = await _client
          .from(_table)
          .insert({
            'match_id': matchId,
            'sender_id': senderId,
            'content': content,
            'image_url': imageUrl,
            'audio_url': audioUrl,
            'is_read': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Message.fromJson(data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark a specific message as read by the current user
  Future<void> markAsRead(String messageId) async {
    try {
      await _client
          .from(_table)
          .update({'is_read': true})
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Count total unread messages across all conversations for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select('id')
          .neq('sender_id', userId)
          .eq('is_read', false);

      final List<dynamic> rows = data as List<dynamic>;
      return rows.length;
    } catch (e) {
      throw Exception('Failed to fetch unread message count: $e');
    }
  }

  // Subscribe to real-time incoming messages for a match
  Stream<Message> subscribeToMessages(String matchId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at')
        .map((rows) => rows.last)
        .where((row) => row.isNotEmpty)
        .map((row) => Message.fromJson(row));
  }

  // Upload an image file to the chat-images bucket and return the public URL
  Future<String> uploadChatImage(File file) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = file.path.split('.').last;
      final filePath = '$userId/chat_$timestamp.$fileExt';

      await _client.storage.from(_chatImagesBucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      return _client.storage.from(_chatImagesBucket).getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload chat image: $e');
    }
  }

  // Upload a voice message file to the voice-messages bucket and return the public URL
  Future<String> uploadVoiceMessage(File file) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$userId/voice_$timestamp.m4a';

      await _client.storage.from(_voiceMessagesBucket).upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      return _client.storage
          .from(_voiceMessagesBucket)
          .getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Failed to upload voice message: $e');
    }
  }
}
