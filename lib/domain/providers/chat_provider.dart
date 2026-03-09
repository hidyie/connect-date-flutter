import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/message_repository.dart';
import 'auth_provider.dart';
import 'match_provider.dart';

// MessageRepository – single instance reused across the app
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// Real-time stream of ALL messages for a specific match (chat room).
// Uses subscribeToMessages which emits each new row as it arrives;
// the UI layer accumulates rows into a list via AsyncValue.
final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, matchId) async* {
  final repository = ref.watch(messageRepositoryProvider);

  // Initial load from REST
  final initial = await repository.getMessages(matchId);
  yield initial;

  // Merge in real-time inserts
  final seen = <String>{};
  for (final m in initial) {
    seen.add(m.id);
  }

  final accumulated = List<Message>.from(initial);

  await for (final newMsg in repository.subscribeToMessages(matchId)) {
    if (!seen.contains(newMsg.id)) {
      seen.add(newMsg.id);
      accumulated.add(newMsg);
      yield List<Message>.from(accumulated);
    }
  }
});

// Chat list with last-message preview.
// Built from confirmed matches; for a full implementation a dedicated
// chat_previews view/RPC on Supabase is recommended.
final chatListProvider = FutureProvider<List<Match>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatches(user.id);
});

// Total unread messages across all conversations
final unreadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repository = ref.watch(messageRepositoryProvider);
  return repository.getUnreadCount(user.id);
});
