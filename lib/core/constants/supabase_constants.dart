class SupabaseConstants {
  SupabaseConstants._();

  // Tables
  static const String profilesTable = 'profiles';
  static const String matchesTable = 'matches';
  static const String messagesTable = 'messages';
  static const String profilePromptsTable = 'profile_prompts';
  static const String premiumSubscriptionsTable = 'premium_subscriptions';
  static const String boostsTable = 'boosts';
  static const String musicPreferencesTable = 'music_preferences';
  static const String photoVerificationsTable = 'photo_verifications';
  static const String blocksTable = 'blocks';
  static const String reportsTable = 'reports';
  static const String safetyCheckinsTable = 'safety_checkins';
  static const String emergencyContactsTable = 'emergency_contacts';
  static const String notificationsTable = 'notifications';
  static const String fcmTokensTable = 'fcm_tokens';
  static const String userRolesTable = 'user_roles';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String voiceMessagesBucket = 'voice-messages';
  static const String chatImagesBucket = 'chat-images';

  // Edge Functions
  static const String aiCompatibilityFunction = 'ai-compatibility';
  static const String aiIcebreakerFunction = 'ai-icebreaker';
  static const String sendPushFunction = 'send-push';
  static const String verifyPhotoFunction = 'verify-photo';
  static const String deleteAccountFunction = 'delete-account';
}
