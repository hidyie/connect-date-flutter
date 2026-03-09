import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/providers/providers.dart';
import '../../presentation/common/main_shell.dart';

// ---------------------------------------------------------------------------
// Existing screens
// ---------------------------------------------------------------------------
import '../../presentation/auth/auth_screen.dart';

// ---------------------------------------------------------------------------
// Placeholder screens – replace with real implementations as they are built.
// ---------------------------------------------------------------------------
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/explore/explore_screen.dart';
import '../../presentation/matches/matches_screen.dart';
import '../../presentation/chat/chats_screen.dart';
import '../../presentation/chat/chat_room_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/profile_detail_screen.dart';
import '../../presentation/premium/premium_screen.dart';
import '../../presentation/admin/admin_screen.dart';
import '../../presentation/common/terms_screen.dart';
import '../../presentation/common/privacy_screen.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------
class AppRoutes {
  const AppRoutes._();

  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const explore = '/explore';
  static const matches = '/matches';
  static const chats = '/chats';
  static const chatRoom = '/chat/:matchId';
  static const profile = '/profile';
  static const userProfile = '/user/:userId';
  static const premium = '/premium';
  static const admin = '/admin';
  static const terms = '/terms';
  static const privacy = '/privacy';

  // Typed path builders
  static String chatRoomPath(String matchId) => '/chat/$matchId';
  static String userProfilePath(String userId) => '/user/$userId';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------
final appRouterProvider = Provider<GoRouter>((ref) {
  // Notifies GoRouter whenever auth state or profile state changes so that
  // the redirect guard is re-evaluated.
  final authNotifier = _AuthStateNotifier(ref);

  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    initialLocation: AppRoutes.explore,

    // ------------------------------------------------------------------
    // Global redirect guard
    // ------------------------------------------------------------------
    redirect: (BuildContext context, GoRouterState state) {
      // Determine authentication status. Fall back to the synchronous getter
      // while the stream is still loading to avoid an unneeded redirect loop.
      final authAsyncValue = ref.read(authStateProvider);
      final isAuthenticated = authAsyncValue.when(
        data: (s) => s.session != null,
        loading: () => Supabase.instance.client.auth.currentUser != null,
        error: (_, __) => false,
      );

      final location = state.matchedLocation;
      final isOnAuth = location == AppRoutes.auth;
      final isOnOnboarding = location == AppRoutes.onboarding;
      final isPublic = location == AppRoutes.terms || location == AppRoutes.privacy;

      // ── Not authenticated ───────────────────────────────────────────
      if (!isAuthenticated) {
        if (isOnAuth || isPublic) return null; // already on a public route
        return AppRoutes.auth;
      }

      // ── Authenticated ───────────────────────────────────────────────

      // If they somehow land on /auth after logging in, send them home.
      if (isOnAuth) return AppRoutes.explore;

      // Onboarding check: only redirect while profile state is settled.
      final profileAsync = ref.read(myProfileProvider);
      final onboardingComplete = profileAsync.when(
        data: (profile) => profile?.onboardingComplete ?? false,
        loading: () => true, // don't redirect while loading – avoid flicker
        error: (_, __) => true, // same – let the screen handle errors
      );

      if (!onboardingComplete && !isOnOnboarding) {
        return AppRoutes.onboarding;
      }
      if (onboardingComplete && isOnOnboarding) {
        return AppRoutes.explore;
      }

      return null; // no redirect needed
    },

    // ------------------------------------------------------------------
    // Route tree
    // ------------------------------------------------------------------
    routes: [
      // ── Pre-auth / public ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Main shell with bottom navigation ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          // Tab 0 – 탐색 (Explore / swipe cards)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          // Tab 1 – 매칭 (Matches)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.matches,
                builder: (context, state) => const MatchesScreen(),
              ),
            ],
          ),
          // Tab 2 – 채팅 (Chats)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chats,
                builder: (context, state) => const ChatsScreen(),
              ),
            ],
          ),
          // Tab 3 – 프로필 (Profile)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (push over the shell) ───────────────────
      GoRoute(
        path: AppRoutes.chatRoom,
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return ChatRoomScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileDetailScreen(userId: userId);
        },
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// [ChangeNotifier] that mirrors Riverpod's auth + profile state so GoRouter
/// can call its [redirect] whenever either changes.
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(myProfileProvider, (_, __) => notifyListeners());
  }
}
