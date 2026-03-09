import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';
import 'package:connect_date/domain/providers/chat_provider.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';
import 'package:connect_date/presentation/admin/admin_screen.dart';
import 'package:connect_date/presentation/auth/auth_screen.dart';
import 'package:connect_date/presentation/chat/chat_room_screen.dart';
import 'package:connect_date/presentation/chat/chats_screen.dart';
import 'package:connect_date/presentation/common/privacy_screen.dart';
import 'package:connect_date/presentation/common/terms_screen.dart';
import 'package:connect_date/presentation/explore/explore_screen.dart';
import 'package:connect_date/presentation/matches/matches_screen.dart';
import 'package:connect_date/presentation/onboarding/onboarding_screen.dart';
import 'package:connect_date/presentation/premium/premium_screen.dart';
import 'package:connect_date/presentation/profile/profile_detail_screen.dart';
import 'package:connect_date/presentation/profile/profile_screen.dart';

// ─────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute) return '/';

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/matches',
            builder: (_, __) => const MatchesScreen(),
          ),
          GoRoute(
            path: '/chats',
            builder: (_, __) => const ChatsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Chat room
      GoRoute(
        path: '/chat/:matchId',
        builder: (_, state) => ChatRoomScreen(matchId: state.pathParameters['matchId']!),
      ),

      // Profile detail
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) => ProfileDetailScreen(userId: state.pathParameters['userId']!),
      ),

      // Premium
      GoRoute(
        path: '/premium',
        builder: (_, __) => const PremiumScreen(),
      ),

      // Admin
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminScreen(),
      ),

      // Legal
      GoRoute(
        path: '/terms',
        builder: (_, __) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('페이지를 찾을 수 없습니다: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────
// App widget
// ─────────────────────────────────────────────

class HeartLinkApp extends ConsumerWidget {
  const HeartLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HeartLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        // Ensure text scaling does not break layouts
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Main shell with bottom navigation
// ─────────────────────────────────────────────

class _MainShell extends ConsumerWidget {
  final Widget child;

  const _MainShell({required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location.startsWith('/matches')) return 1;
    if (location.startsWith('/chats')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                case 1:
                  context.go('/matches');
                case 2:
                  context.go('/chats');
                case 3:
                  context.go('/profile');
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: '탐색',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: '매칭',
              ),
              BottomNavigationBarItem(
                icon: _UnreadBadgeIcon(ref: ref),
                activeIcon: const Icon(Icons.chat_bubble),
                label: '메시지',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '프로필',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadBadgeIcon extends ConsumerWidget {
  final WidgetRef ref;

  const _UnreadBadgeIcon({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadCountProvider);
    final unread = unreadAsync.value ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.chat_bubble_outline),
        if (unread > 0)
          Positioned(
            top: -6,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
