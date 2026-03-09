import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/match_repository.dart';
import 'auth_provider.dart';

// MatchRepository – single instance reused across the app
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

// Fetches the list of confirmed (status == 'matched') matches for the current user
final matchesProvider = FutureProvider<List<Match>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(matchRepositoryProvider);
  return repository.getMatches(user.id);
});

// Fetches outgoing pending likes for the current user
final pendingMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repository = ref.watch(matchRepositoryProvider);
  return repository.getPendingMatches(user.id);
});
