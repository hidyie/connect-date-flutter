import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

// NotificationRepository – single instance reused across the app
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Real-time stream of notifications for the current user.
// Uses subscribeToNotifications which emits each new row as it arrives;
// UI accumulates into a list similarly to messagesProvider.
final notificationsProvider =
    StreamProvider<List<AppNotification>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield const [];
    return;
  }

  final repository = ref.watch(notificationRepositoryProvider);

  // Initial fetch
  final initial = await repository.getNotifications(user.id);
  yield initial;

  final seen = <String>{};
  for (final n in initial) {
    seen.add(n.id);
  }
  final accumulated = List<AppNotification>.from(initial);

  await for (final newNote
      in repository.subscribeToNotifications(user.id)) {
    if (!seen.contains(newNote.id)) {
      seen.add(newNote.id);
      accumulated.insert(0, newNote); // newest first
      yield List<AppNotification>.from(accumulated);
    }
  }
});

// Total number of unread notifications
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount(user.id);
});
