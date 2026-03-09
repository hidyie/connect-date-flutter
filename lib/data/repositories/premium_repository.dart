import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PremiumRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = 'premium_subscriptions';

  // Fetch the premium subscription record for a given user
  Future<PremiumSubscription?> getSubscription(String userId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return PremiumSubscription.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch subscription for user $userId: $e');
    }
  }

  // Create or update a premium subscription with a plan and optional config
  Future<PremiumSubscription> updateSubscription(
    String plan,
    Map<String, dynamic> config,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('No authenticated user found');

      final data = await _client
          .from(_table)
          .upsert({
            'user_id': userId,
            'plan': plan,
            'config': config,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return PremiumSubscription.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Check whether the user currently holds an active premium subscription
  Future<bool> isPremium(String userId) async {
    try {
      final subscription = await getSubscription(userId);
      if (subscription == null) return false;

      return subscription.isPremium && subscription.isActive;
    } catch (e) {
      throw Exception('Failed to check premium status for user $userId: $e');
    }
  }
}
