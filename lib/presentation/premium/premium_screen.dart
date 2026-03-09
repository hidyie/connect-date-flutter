import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connect_date/core/constants/app_constants.dart';
import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/domain/providers/premium_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final premiumAsync = ref.watch(premiumProvider);
    final currentPlan = premiumAsync.value?.plan ?? 'free';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('프리미엄', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero header
            _buildHeroHeader(),
            const SizedBox(height: 24),

            // Plan cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _PlanCard(
                    plan: 'free',
                    title: 'Free',
                    price: '무료',
                    gradient: const [Color(0xFF374151), Color(0xFF1F2937)],
                    isCurrent: currentPlan == 'free',
                    features: const [
                      _Feature(label: '하루 30개 좋아요', available: true),
                      _Feature(label: '슈퍼 좋아요 3개/일', available: true),
                      _Feature(label: '기본 매칭', available: true),
                      _Feature(label: '무제한 되감기', available: false),
                      _Feature(label: '좋아요한 사람 보기', available: false),
                      _Feature(label: '월 1회 부스트', available: false),
                      _Feature(label: 'AI 궁합 분석 10회/일', available: false),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  _PlanCard(
                    plan: 'gold',
                    title: 'Gold',
                    price: '₩${_formatPrice(AppConstants.goldPrice)}/월',
                    gradient: const [Color(0xFFD4A017), Color(0xFF92620A)],
                    isCurrent: currentPlan == 'gold',
                    badge: 'BEST',
                    features: const [
                      _Feature(label: '하루 100개 좋아요', available: true),
                      _Feature(label: '슈퍼 좋아요 3개/일', available: true),
                      _Feature(label: '무제한 되감기 5회/일', available: true),
                      _Feature(label: '좋아요한 사람 보기', available: true),
                      _Feature(label: '월 1회 부스트', available: true),
                      _Feature(label: 'AI 궁합 분석 10회/일', available: true),
                      _Feature(label: '아이스브레이커 3개/매칭', available: true),
                    ],
                    onSubscribe: () => _handleSubscribe(context, 'gold'),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  _PlanCard(
                    plan: 'platinum',
                    title: 'Platinum',
                    price: '₩${_formatPrice(AppConstants.platinumPrice)}/월',
                    gradient: const [Color(0xFF9333EA), Color(0xFF6D28D9)],
                    isCurrent: currentPlan == 'platinum',
                    badge: 'PREMIUM',
                    features: const [
                      _Feature(label: '하루 300개 좋아요', available: true),
                      _Feature(label: '슈퍼 좋아요 10개/일', available: true),
                      _Feature(label: '무제한 되감기 15회/일', available: true),
                      _Feature(label: '좋아요한 사람 보기', available: true),
                      _Feature(label: '월 3회 부스트', available: true),
                      _Feature(label: 'AI 궁합 분석 30회/일', available: true),
                      _Feature(label: '아이스브레이커 10개/매칭', available: true),
                    ],
                    onSubscribe: () => _handleSubscribe(context, 'platinum'),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '구독은 언제든지 취소할 수 있습니다.\n결제는 구글 플레이 스토어 또는 앱 스토어를 통해 처리됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A017), Color(0xFF9333EA)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 44),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text(
            'HeartLink 프리미엄',
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            '더 많은 매칭과 기능으로\n특별한 인연을 만나보세요',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15, height: 1.5),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  void _handleSubscribe(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${plan == 'gold' ? 'Gold' : 'Platinum'} 구독'),
        content: Text(
          '${plan == 'gold' ? 'Gold (₩${_formatPrice(AppConstants.goldPrice)}/월)' : 'Platinum (₩${_formatPrice(AppConstants.platinumPrice)}/월)'} 플랜을 구독하시겠습니까?\n\n결제는 앱 스토어를 통해 처리됩니다.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결제 처리 중... (인앱 결제 연동 필요)')),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }

  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _Feature {
  final String label;
  final bool available;

  const _Feature({required this.label, required this.available});
}

class _PlanCard extends StatelessWidget {
  final String plan;
  final String title;
  final String price;
  final List<Color> gradient;
  final bool isCurrent;
  final String? badge;
  final List<_Feature> features;
  final VoidCallback? onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.title,
    required this.price,
    required this.gradient,
    required this.isCurrent,
    this.badge,
    required this.features,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24),
        border: isCurrent
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '현재 플랜',
                      style: TextStyle(color: gradient.first, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),

            // Features
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    f.available ? Icons.check_circle : Icons.cancel,
                    color: f.available ? Colors.white : Colors.white38,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    f.label,
                    style: TextStyle(
                      color: f.available ? Colors.white : Colors.white38,
                      fontSize: 14,
                      fontWeight: f.available ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )),

            // Subscribe button (for non-free plans)
            if (plan != 'free' && !isCurrent) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: gradient.first,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    elevation: 0,
                  ),
                  child: Text('$title 구독하기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
