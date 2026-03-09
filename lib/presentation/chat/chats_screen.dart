import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/match.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';
import 'package:connect_date/domain/providers/chat_provider.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('메시지', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: chatListAsync.when(
        loading: () => _buildSkeletonList(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              const Text('채팅 목록을 불러올 수 없습니다'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(chatListProvider),
                style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (matches) {
          if (matches.isEmpty) return _buildEmptyState(context);
          return ListView.separated(
            itemCount: matches.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 84,
              color: Colors.grey.shade100,
            ),
            itemBuilder: (context, index) {
              final match = matches[index];
              return _ChatListItem(match: match, index: index);
            },
          );
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
            child: const Icon(Icons.chat_bubble_outline, size: 56, color: AppTheme.primaryColor),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            '아직 대화가 없어요',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            '매칭된 상대와 대화를 시작해보세요!',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/matches'),
            icon: const Icon(Icons.favorite_outline),
            label: const Text('매칭 보러 가기'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(180, 50)),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, index) => const _SkeletonItem(),
    );
  }
}

class _ChatListItem extends ConsumerWidget {
  final Match match;
  final int index;

  const _ChatListItem({required this.match, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUserId = ref.watch(currentUserProvider)?.id ?? '';
    final partnerUserId = match.userId == myUserId ? match.targetUserId : match.userId;
    final profileAsync = ref.watch(profileProvider(partnerUserId));
    final messagesAsync = ref.watch(messagesProvider(match.id));

    final partnerName = profileAsync.value?.displayName ?? '...';
    final avatarUrl = profileAsync.value?.avatarUrl;

    String lastMessage = '대화를 시작해보세요';
    DateTime? lastMessageAt;
    int unreadCount = 0;

    if (messagesAsync.value != null && messagesAsync.value!.isNotEmpty) {
      final msgs = messagesAsync.value!;
      final last = msgs.last;
      lastMessage = last.hasImage ? '사진을 보냈습니다' : (last.content.isEmpty ? '미디어' : last.content);
      lastMessageAt = last.createdAt;
      unreadCount = msgs.where((m) => !m.read && m.senderId != myUserId).length;
    }

    return InkWell(
      onTap: () => context.push('/chat/${match.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with unread indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: unreadCount > 0 ? AppTheme.primaryColor : Colors.grey.shade200,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _avatarPlaceholder(),
                          )
                        : _avatarPlaceholder(),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name & last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Timestamp
            if (lastMessageAt != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatTime(lastMessageAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: unreadCount > 0 ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(dt);
    } else if (diff.inDays == 1) {
      return '어제';
    } else if (diff.inDays < 7) {
      return DateFormat('EEE', 'ko_KR').format(dt);
    } else {
      return DateFormat('MM/dd').format(dt);
    }
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: const Center(child: Icon(Icons.person, color: AppTheme.primaryColor, size: 28)),
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
