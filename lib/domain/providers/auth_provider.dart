import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/auth_repository.dart';

// AuthRepository – single instance reused across the app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Stream of Supabase auth state changes (AuthState events)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// Convenience provider: returns the current User or null synchronously
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    // While the stream is loading fall back to the synchronous getter
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (_, __) => null,
  );
});
