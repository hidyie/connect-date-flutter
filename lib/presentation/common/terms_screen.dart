import 'package:flutter/material.dart';

import 'package:connect_date/core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('이용약관', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LegalHeader(
          title: 'HeartLink 서비스 이용약관',
          lastUpdated: '최종 업데이트: 2024년 1월 1일',
        ),
        SizedBox(height: 24),
        _LegalSection(
          title: '제1조 (목적)',
          content:
              '본 약관은 HeartLink (이하 "서비스")를 이용함에 있어 서비스 제공자와 이용자 간의 권리, 의무 및 책임사항을 규정하는 것을 목적으로 합니다. 서비스를 이용하시기 전에 본 약관을 주의 깊게 읽어 주시기 바랍니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제2조 (정의)',
          content:
              '"서비스"란 HeartLink가 제공하는 소셜 데이팅 플랫폼 및 관련 서비스를 의미합니다.\n"이용자"란 본 약관에 따라 서비스를 이용하는 모든 사람을 의미합니다.\n"콘텐츠"란 이용자가 서비스를 통해 게시, 전송, 공유하는 모든 정보를 의미합니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제3조 (회원가입 및 자격)',
          content:
              '서비스를 이용하기 위해서는 만 18세 이상이어야 합니다.\n회원가입 시 제공하는 모든 정보는 사실이어야 하며, 허위 정보 제공 시 서비스 이용이 제한될 수 있습니다.\n하나의 이용자는 하나의 계정만 보유할 수 있습니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제4조 (서비스 이용)',
          content:
              '이용자는 서비스를 합법적인 목적으로만 이용해야 합니다.\n다른 이용자를 괴롭히거나 해치는 행위, 스팸 발송, 사기 행위는 엄격히 금지됩니다.\n서비스를 통해 수집한 다른 이용자의 개인정보를 무단으로 사용하거나 유포하는 것은 금지됩니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제5조 (금지 행위)',
          content:
              '다음 행위는 서비스에서 엄격히 금지됩니다:\n• 허위 신원 또는 허위 프로필 생성\n• 미성년자에 대한 부적절한 접근\n• 불법적인 콘텐츠 게시 또는 공유\n• 타인의 개인정보 무단 수집\n• 서비스 시스템 해킹 또는 조작 시도\n• 상업적 목적의 무단 광고 행위',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제6조 (프리미엄 서비스)',
          content:
              '서비스는 무료 기본 서비스와 유료 프리미엄 서비스를 제공합니다.\n프리미엄 서비스 구독은 자동으로 갱신되며, 다음 결제일 24시간 전까지 취소할 수 있습니다.\n환불 정책은 각 앱 스토어의 환불 정책을 따릅니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제7조 (서비스 변경 및 중단)',
          content:
              '서비스는 사전 공지 없이 서비스의 내용을 변경하거나 중단할 수 있습니다.\n다만, 유료 서비스의 경우 합리적인 기간 전에 공지하겠습니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제8조 (면책 조항)',
          content:
              '서비스는 이용자 간의 교류에서 발생하는 분쟁이나 피해에 대해 책임을 지지 않습니다.\n서비스 이용 중 발생하는 손해에 대해 서비스의 고의 또는 중대한 과실이 없는 한 책임을 지지 않습니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제9조 (약관 변경)',
          content:
              '약관을 변경할 경우, 변경 내용과 시행일을 서비스 내에 공지합니다.\n변경된 약관에 동의하지 않는 경우 서비스 이용을 중단하고 탈퇴할 수 있습니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '제10조 (분쟁 해결)',
          content:
              '본 약관과 관련된 분쟁은 대한민국 법률에 따라 해결됩니다.\n분쟁이 발생할 경우 상호 협의를 통해 해결하며, 협의가 이루어지지 않는 경우 관할 법원에 소를 제기할 수 있습니다.',
        ),
        SizedBox(height: 40),
        _LegalFooter(company: 'HeartLink 운영팀'),
      ],
    );
  }
}

class _LegalHeader extends StatelessWidget {
  final String title;
  final String lastUpdated;

  const _LegalHeader({required this.title, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(lastUpdated, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        const Divider(color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String content;

  const _LegalSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.7),
        ),
      ],
    );
  }
}

class _LegalFooter extends StatelessWidget {
  final String company;

  const _LegalFooter({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '문의사항이 있으시면 $company(support@heartlink.app)로 연락해 주세요.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
