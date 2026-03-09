import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/profile_repository.dart';
import 'auth_provider.dart';

// ProfileRepository – single instance reused across the app
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Fetches the currently logged-in user's own profile
final myProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(user.id);
});

// Fetches any user's profile by userId
final profileProvider =
    FutureProvider.family<Profile?, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(userId);
});

// Fetches nearby / discoverable profiles for the Explore screen.
// Uses sensible defaults; callers can override by passing a dedicated
// filter state provider once filter UI is built.
final nearbyProfilesProvider = FutureProvider<List<Profile>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final myProfile = await ref.watch(myProfileProvider.future);
  if (myProfile == null) return [];

  final lat = myProfile.latitude ?? 37.5665; // default: Seoul
  final lng = myProfile.longitude ?? 126.9780;

  final repository = ref.watch(profileRepositoryProvider);
  return repository.getNearbyProfiles(
    lat: lat,
    lng: lng,
    maxDistance: 50.0, // km
    ageMin: myProfile.minAge,
    ageMax: myProfile.maxAge,
    genderFilter: myProfile.lookingFor,
    excludeIds: [user.id],
  );
});
