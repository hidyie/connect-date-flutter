import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/match.dart';
import 'package:connect_date/data/models/profile.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';
import 'package:connect_date/domain/providers/match_provider.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('매칭', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('매칭 목록을 불러올 수 없습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(matchesProvider),
                style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (matches) {
          if (matches.isEmpty) return _buildEmptyState(context);
          return _buildMatchGrid(context, ref, matches);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border, size: 56, color: AppTheme.primaryColor),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            '아직 매칭이 없어요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            '탐색 화면에서 마음에 드는 사람에게\n좋아요를 보내보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.explore_outlined),
            label: const Text('탐색하러 가기'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 50)),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildMatchGrid(BuildContext context, WidgetRef ref, List<Match> matches) {
    final currentUserId = ref.read(currentUserProvider)?.id ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '총 ${matches.length}명',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final partnerUserId = match.userId == currentUserId
                    ? match.targetUserId
                    : match.userId;
                return _MatchCard(
                  match: match,
                  partnerUserId: partnerUserId,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  final Match match;
  final String partnerUserId;
  final int index;

  const _MatchCard({
    required this.match,
    required this.partnerUserId,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(partnerUserId));

    return profileAsync.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => _buildErrorCard(),
      data: (profile) {
        if (profile == null) return _buildErrorCard();
        return _buildCard(context, profile);
      },
    );
  }

  Widget _buildCard(BuildContext context, Profile profile) {
    return GestureDetector(
      onTap: () => context.push('/chat/${match.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              if (profile.avatarUrl != null)
                CachedNetworkImage(
                  imageUrl: profile.avatarUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _photoPlaceholder(),
                )
              else
                _photoPlaceholder(),

              // Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
              ),

              // Super like star
              if (match.isSuperLike)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.warningColor.withOpacity(0.5), blurRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 16),
                  ),
                ),

              // Name & age
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${profile.age}세 · ${profile.city}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * index), duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: AppTheme.textSecondary, size: 40),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: const Center(
        child: Icon(Icons.person, size: 64, color: AppTheme.primaryColor),
      ),
    );
  }
}
