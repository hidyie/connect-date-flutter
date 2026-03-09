import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/profile.dart';
import 'package:connect_date/data/repositories/match_repository.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  final PageController _photoController = PageController();
  int _currentPhotoIndex = 0;
  bool _isActing = false;

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _sendLike({required bool isSuperLike}) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    setState(() => _isActing = true);
    try {
      final repo = MatchRepository();
      await repo.createMatch(widget.userId, isSuperLike: isSuperLike);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSuperLike ? '슈퍼 좋아요를 보냈습니다!' : '좋아요를 보냈습니다!'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _showReportDialog() {
    final reasons = ['스팸', '부적절한 사진', '불쾌한 발언', '사기 의심', '기타'];
    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('신고하기'),
        content: StatefulBuilder(
          builder: (ctx, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((reason) => RadioListTile<String>(
              value: reason,
              groupValue: selectedReason,
              title: Text(reason),
              onChanged: (v) => setDialogState(() => selectedReason = v!),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(widget.userId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (_, __) => const Center(child: Text('프로필을 불러올 수 없습니다')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('프로필이 없습니다'));
          return _buildContent(profile);
        },
      ),
    );
  }

  Widget _buildContent(Profile profile) {
    final photos = <String>[
      if (profile.avatarUrl != null) profile.avatarUrl!,
      ...profile.photos,
    ];

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Photo carousel
            SliverAppBar(
              expandedHeight: 420,
              pinned: true,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: const Icon(Icons.flag_outlined, color: Colors.white, size: 18),
                  ),
                  onPressed: _showReportDialog,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Photo PageView
                    photos.isEmpty
                        ? Container(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Center(child: Icon(Icons.person, size: 100, color: AppTheme.primaryColor)),
                          )
                        : PageView.builder(
                            controller: _photoController,
                            itemCount: photos.length,
                            onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
                            itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: photos[i],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                child: const Icon(Icons.person, size: 100, color: AppTheme.primaryColor),
                              ),
                            ),
                          ),

                    // Page indicators
                    if (photos.length > 1)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(photos.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _currentPhotoIndex == i ? 20 : 6,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: _currentPhotoIndex == i ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ),

                    // Compatibility badge
                    Positioned(
                      top: 50,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [BoxShadow(color: AppTheme.successColor.withOpacity(0.4), blurRadius: 8)],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('85% 궁합', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    // Gradient bottom overlay
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.6, 1.0],
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ),

                    // Name & basic info
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${profile.displayName}, ${profile.age}',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(profile.city, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      _detailSection(
                        icon: Icons.person_outline,
                        title: '자기 소개',
                        child: Text(
                          profile.bio!,
                          style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Interests
                    if (profile.interests.isNotEmpty) ...[
                      _detailSection(
                        icon: Icons.interests_outlined,
                        title: '관심사',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                              ),
                              child: Text(interest, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Music preferences placeholder
                    _detailSection(
                      icon: Icons.music_note_outlined,
                      title: '음악 취향',
                      child: const Text(
                        'Spotify 연동 시 나타납니다',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Looking for
                    _detailSection(
                      icon: Icons.search,
                      title: '원하는 상대',
                      child: _InfoChip(label: profile.lookingFor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bottom action bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(
              left: 32,
              right: 32,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Pass
                _ActionButton(
                  icon: Icons.close,
                  label: '패스',
                  color: Colors.grey.shade400,
                  size: 56,
                  onTap: () => Navigator.of(context).pop(),
                ),
                // Super Like
                _ActionButton(
                  icon: Icons.star,
                  label: '슈퍼 좋아요',
                  color: AppTheme.warningColor,
                  size: 50,
                  onTap: _isActing ? null : () => _sendLike(isSuperLike: true),
                ),
                // Like
                _ActionButton(
                  icon: Icons.favorite,
                  label: '좋아요',
                  color: AppTheme.primaryColor,
                  size: 56,
                  onTap: _isActing ? null : () => _sendLike(isSuperLike: false),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),
        ),
      ],
    );
  }

  Widget _detailSection({required IconData icon, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(label, style: const TextStyle(color: AppTheme.textPrimary)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: size * 0.48),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
