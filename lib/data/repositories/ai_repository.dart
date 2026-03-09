import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AiRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _compatibilityFunction = 'ai-compatibility';
  static const String _icebreakerFunction = 'ai-icebreaker';
  static const String _verifyPhotoFunction = 'verify-photo';

  // Invoke the ai-compatibility edge function to score two users' compatibility
  Future<Map<String, dynamic>> getCompatibilityAnalysis({
    required Profile myProfile,
    required Profile otherProfile,
    required List<Map<String, dynamic>> myPrompts,
    required List<Map<String, dynamic>> otherPrompts,
  }) async {
    try {
      final response = await _client.functions.invoke(
        _compatibilityFunction,
        body: {
          'my_profile': myProfile.toJson(),
          'other_profile': otherProfile.toJson(),
          'my_prompts': myPrompts,
          'other_prompts': otherPrompts,
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from compatibility function');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      throw Exception('Compatibility analysis failed: ${e.details}');
    } catch (e) {
      throw Exception('Unexpected error during compatibility analysis: $e');
    }
  }

  // Invoke the ai-icebreaker edge function to generate conversation starters
  Future<List<String>> getIcebreakerSuggestions({
    required Profile myProfile,
    required Profile partnerProfile,
    required List<Map<String, dynamic>> myPrompts,
    required List<Map<String, dynamic>> partnerPrompts,
  }) async {
    try {
      final response = await _client.functions.invoke(
        _icebreakerFunction,
        body: {
          'my_profile': myProfile.toJson(),
          'partner_profile': partnerProfile.toJson(),
          'my_prompts': myPrompts,
          'partner_prompts': partnerPrompts,
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from icebreaker function');
      }

      final suggestions = response.data['suggestions'];
      if (suggestions == null || suggestions is! List) {
        throw Exception('Invalid icebreaker response format');
      }

      return List<String>.from(suggestions);
    } on FunctionException catch (e) {
      throw Exception('Icebreaker suggestion failed: ${e.details}');
    } catch (e) {
      throw Exception('Unexpected error during icebreaker suggestion: $e');
    }
  }

  // Invoke the verify-photo edge function to confirm a selfie matches a profile photo
  Future<Map<String, dynamic>> verifyPhoto({
    required String selfieUrl,
    required String profilePhotoUrl,
  }) async {
    try {
      final response = await _client.functions.invoke(
        _verifyPhotoFunction,
        body: {
          'selfie_url': selfieUrl,
          'profile_photo_url': profilePhotoUrl,
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from photo verification function');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } on FunctionException catch (e) {
      throw Exception('Photo verification failed: ${e.details}');
    } catch (e) {
      throw Exception('Unexpected error during photo verification: $e');
    }
  }
}
