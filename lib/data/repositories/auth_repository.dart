import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Sign up a new user with email and password
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during sign up: $e');
    }
  }

  // Sign in an existing user with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during sign in: $e');
    }
  }

  // Sign in using Google OAuth
  Future<AuthResponse> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.heartlink://login-callback/',
      );
      // Return current session after OAuth redirect completes
      final session = _client.auth.currentSession;
      final user = _client.auth.currentUser;
      return AuthResponse(session: session, user: user);
    } on AuthException catch (e) {
      throw Exception('Google sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during Google sign in: $e');
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during sign out: $e');
    }
  }

  // Get the currently authenticated user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Stream of auth state changes for reactive UI
  Stream<AuthState> get onAuthStateChange {
    return _client.auth.onAuthStateChange;
  }

  // Send a password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.heartlink://reset-callback/',
      );
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during password reset: $e');
    }
  }

  // Permanently delete the current user's account via edge function
  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete-account');
      await _client.auth.signOut();
    } on FunctionException catch (e) {
      throw Exception('Account deletion failed: ${e.details}');
    } catch (e) {
      throw Exception('Unexpected error during account deletion: $e');
    }
  }
}
