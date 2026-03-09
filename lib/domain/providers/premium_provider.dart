import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/premium_repository.dart';
import 'auth_provider.dart';

// PremiumRepository – single instance reused across the app
final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumRepository();
});

// Fetches the current user's PremiumSubscription record
final premiumProvider = FutureProvider<PremiumSubscription?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(premiumRepositoryProvider);
  return repository.getSubscription(user.id);
});

// Convenience bool: true when the user has an active premium plan
final isPremiumProvider = Provider<bool>((ref) {
  final subscription = ref.watch(premiumProvider);
  return subscription.when(
    data: (sub) => sub != null && sub.isPremium && sub.isActive,
    loading: () => false,
    error: (_, __) => false,
  );
});
