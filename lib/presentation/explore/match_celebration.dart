import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/profile.dart';
import 'package:connect_date/domain/providers/profile_provider.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';

class MatchCelebrationOverlay extends ConsumerStatefulWidget {
  final Profile matchedProfile;
  final String matchId;

  const MatchCelebrationOverlay({
    super.key,
    required this.matchedProfile,
    required this.matchId,
  });

  @override
  ConsumerState<MatchCelebrationOverlay> createState() => _MatchCelebrationOverlayState();
}

class _MatchCelebrationOverlayState extends ConsumerState<MatchCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.5,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 6 + _random.nextDouble() * 10,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        rotation: _random.nextDouble() * pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        isCircle: _random.nextBool(),
      ));
    }
  }

  static const List<Color> _confettiColors = [
    AppTheme.primaryColor,
    Color(0xFFFBBF24),
    Color(0xFF34D399),
    Color(0xFF60A5FA),
    Color(0xFFA78BFA),
    Color(0xFFF87171),
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final myProfile = myProfileAsync.value;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dark overlay background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE6E11D48),
                  Color(0xE69F1239),
                ],
              ),
            ),
          ),

          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Celebration icon
                const Icon(Icons.favorite, color: Colors.white, size: 48)
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .then()
                    .shake(duration: 500.ms),

                const SizedBox(height: 20),

                const Text(
                  '매칭 성공!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.5, end: 0),

                const SizedBox(height: 8),

                const Text(
                  '서로가 좋아요를 눌렀어요!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 48),

                // Profile photos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfilePhoto(
                      imageUrl: myProfile?.avatarUrl,
                      name: myProfile?.displayName ?? '나',
                      isMe: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite, color: AppTheme.primaryColor, size: 28),
                      ),
                    ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.elasticOut),
                    _buildProfilePhoto(
                      imageUrl: widget.matchedProfile.avatarUrl,
                      name: widget.matchedProfile.displayName,
                      isMe: false,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 16),

                Text(
                  '${widget.matchedProfile.displayName}님과 매칭됐어요!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const Spacer(),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/chat/${widget.matchId}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('메시지 보내기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 12),

                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('계속 탐색하기'),
                      ).animate().fadeIn(delay: 800.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto({
    required String? imageUrl,
    required String name,
    required bool isMe,
  }) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppTheme.primaryLight,
      child: const Icon(Icons.person, color: Colors.white, size: 52),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;

  const _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      final y = p.startY + progress * p.speed;
      if (y < 0 || y > 1.1) continue;

      final dx = p.x * size.width;
      final dy = y * size.height;
      final currentRotation = p.rotation + progress * p.rotationSpeed * 20;

      paint.color = p.color.withOpacity(0.85);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(currentRotation);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
