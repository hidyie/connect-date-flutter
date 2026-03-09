import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/profile.dart';
import 'package:connect_date/data/repositories/match_repository.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';
import 'package:connect_date/domain/providers/premium_provider.dart';
import 'package:connect_date/presentation/explore/match_celebration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  int _superLikesToday = 0;
  static const int _maxSuperLikes = 3;

  @override
  void initState() {
    super.initState();
    _loadSuperLikeCount();
  }

  Future<void> _loadSuperLikeCount() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final repo = MatchRepository();
      final count = await repo.getSuperLikeCountToday(user.id);
      if (mounted) setState(() => _superLikesToday = count);
    } catch (_) {}
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _handleSwipe(Profile profile, {required bool isLike, required bool isSuperLike}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    if (isSuperLike) {
      final isPremium = ref.read(isPremiumProvider);
      if (!isPremium && _superLikesToday >= _maxSuperLikes) {
        _showSuperLikeLimitDialog();
        return;
      }
    }

    try {
      final repo = MatchRepository();
      if (isLike || isSuperLike) {
        final match = await repo.createMatch(profile.userId, isSuperLike: isSuperLike);
        if (isSuperLike) setState(() => _superLikesToday++);

        // Check for mutual match
        if (match.isMatched && mounted) {
          _showMatchCelebration(profile, matchId: match.id);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _showMatchCelebration(Profile profile, {required String matchId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => MatchCelebrationOverlay(
        matchedProfile: profile,
        matchId: matchId,
      ),
    );
  }

  void _showSuperLikeLimitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('슈퍼 좋아요 소진'),
        content: const Text('오늘의 무료 슈퍼 좋아요 3개를 모두 사용했습니다.\nGold 플랜으로 업그레이드하면 더 많은 슈퍼 좋아요를 사용할 수 있어요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate to premium screen
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(nearbyProfilesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite, color: AppTheme.primaryColor, size: 24),
            SizedBox(width: 8),
            Text('탐색', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () {/* Filter settings */},
          ),
        ],
      ),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('프로필을 불러올 수 없습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(nearbyProfilesProvider),
                style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (profiles) {
          if (profiles.isEmpty) return _buildEmptyState();
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: profiles.length,
                    numberOfCardsDisplayed: profiles.length > 2 ? 3 : profiles.length,
                    backCardOffset: const Offset(0, 24),
                    scale: 0.9,
                    padding: EdgeInsets.zero,
                    onSwipe: (previousIndex, currentIndex, direction) {
                      final profile = profiles[previousIndex];
                      if (direction == CardSwiperDirection.right) {
                        _handleSwipe(profile, isLike: true, isSuperLike: false);
                      } else if (direction == CardSwiperDirection.left) {
                        _handleSwipe(profile, isLike: false, isSuperLike: false);
                      } else if (direction == CardSwiperDirection.top) {
                        _handleSwipe(profile, isLike: false, isSuperLike: true);
                      }
                      return true;
                    },
                    cardBuilder: (context, index, horizontalOffset, verticalOffset) {
                      return _ProfileCard(profile: profiles[index]);
                    },
                  ),
                ),
              ),
              _buildActionButtons(profiles),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300)
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            '근처에 새로운 프로필이 없어요',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            '나중에 다시 확인해보세요!',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(nearbyProfilesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('새로고침'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(List<Profile> profiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reject
          _ActionButton(
            icon: Icons.close,
            color: Colors.grey.shade400,
            size: 56,
            onTap: () => _swiperController.swipe(CardSwiperDirection.left),
          ),
          // Super Like
          _ActionButton(
            icon: Icons.star,
            color: AppTheme.warningColor,
            size: 48,
            badge: _superLikesToday < _maxSuperLikes
                ? '${_maxSuperLikes - _superLikesToday}'
                : null,
            onTap: () => _swiperController.swipe(CardSwiperDirection.top),
          ),
          // Like
          _ActionButton(
            icon: Icons.favorite,
            color: AppTheme.primaryColor,
            size: 56,
            onTap: () => _swiperController.swipe(CardSwiperDirection.right),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Profile profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final photos = profile.photos.isNotEmpty ? profile.photos : <String>[];
    final imageUrl = profile.avatarUrl ?? (photos.isNotEmpty ? photos.first : null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),

            // Profile info at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.displayName}, ${profile.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Compatibility badge placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('85%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        profile.city,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (profile.interests.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: profile.interests.take(4).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Icon(Icons.person, size: 100, color: Colors.grey.shade300),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final String? badge;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: size * 0.48),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}
