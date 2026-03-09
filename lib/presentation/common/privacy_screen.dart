import 'package:flutter/material.dart';

import 'package:connect_date/core/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('개인정보처리방침', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _LegalHeader(
          title: 'HeartLink 개인정보처리방침',
          lastUpdated: '최종 업데이트: 2024년 1월 1일',
        ),
        SizedBox(height: 24),
        _LegalSection(
          title: '1. 수집하는 개인정보의 종류',
          content:
              'HeartLink는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다:\n\n• 필수 정보: 이메일 주소, 이름(닉네임), 생년월일, 성별\n• 선택 정보: 프로필 사진, 자기소개, 관심사, 위치 정보\n• 자동 수집 정보: 기기 정보, IP 주소, 앱 사용 기록, 쿠키',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '2. 개인정보의 수집 방법',
          content:
              '• 회원가입 및 프로필 작성 시 이용자가 직접 제공\n• 소셜 로그인(Google 등)을 통한 연동\n• 서비스 이용 과정에서 자동으로 생성 및 수집\n• 고객센터 문의 시 이용자가 제공',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '3. 개인정보의 이용 목적',
          content:
              '수집된 개인정보는 다음 목적으로 이용됩니다:\n\n• 서비스 제공 및 이용자 식별\n• 매칭 알고리즘을 통한 적합한 상대 추천\n• 고객 지원 및 서비스 개선\n• 불법 행위 방지 및 안전한 서비스 환경 유지\n• 서비스 관련 공지사항 전달\n• 프리미엄 서비스 제공 및 결제 처리',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '4. 개인정보의 보유 및 이용 기간',
          content:
              '개인정보는 수집 목적이 달성된 후 즉시 파기하는 것을 원칙으로 합니다.\n\n• 회원 정보: 회원 탈퇴 후 즉시 삭제 (단, 관련 법령에 따라 일정 기간 보관)\n• 서비스 이용 기록: 3년 보관 (통신비밀보호법)\n• 결제 기록: 5년 보관 (전자상거래 등에서의 소비자보호에 관한 법률)',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '5. 개인정보의 제3자 제공',
          content:
              'HeartLink는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다.\n단, 다음의 경우에는 예외로 합니다:\n\n• 이용자가 사전에 동의한 경우\n• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '6. 위치 정보 처리',
          content:
              '서비스는 근처의 이용자를 찾기 위해 위치 정보를 수집할 수 있습니다.\n위치 정보 수집은 이용자의 동의 후에만 이루어지며, 언제든지 거부할 수 있습니다.\n정확한 위치는 저장되지 않으며, 거리 계산을 위한 대략적인 위치만 활용됩니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '7. 이용자의 권리',
          content:
              '이용자는 언제든지 다음 권리를 행사할 수 있습니다:\n\n• 개인정보 열람 요청\n• 개인정보 정정 또는 삭제 요청\n• 개인정보 처리 정지 요청\n• 개인정보 이동 요청\n\n권리 행사는 앱 내 설정 또는 고객센터를 통해 가능합니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '8. 개인정보의 안전성 확보 조치',
          content:
              'HeartLink는 개인정보 보호를 위해 다음과 같은 조치를 취하고 있습니다:\n\n• 데이터 암호화: 전송 중 및 저장 시 데이터 암호화\n• 접근 제한: 최소한의 인원만 개인정보에 접근 가능\n• 정기적 보안 점검: 취약점 점검 및 보안 업데이트\n• Supabase Row Level Security를 통한 데이터 접근 제어',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '9. 쿠키 및 유사 기술',
          content:
              '서비스는 이용자 경험 향상을 위해 쿠키 및 유사 기술을 사용할 수 있습니다.\n이용자는 기기 설정을 통해 쿠키 사용을 거부할 수 있으나, 일부 서비스 기능이 제한될 수 있습니다.',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '10. 개인정보 보호 책임자',
          content:
              '개인정보 관련 문의, 불만 처리, 피해 구제 등에 관한 사항은 아래의 담당자에게 연락해 주십시오.\n\n개인정보 보호 책임자: HeartLink 운영팀\n이메일: privacy@heartlink.app\n처리 시간: 평일 09:00 ~ 18:00',
        ),
        SizedBox(height: 20),
        _LegalSection(
          title: '11. 방침 변경',
          content:
              '개인정보처리방침이 변경될 경우, 변경 7일 전부터 앱 내 공지사항을 통해 안내해 드리겠습니다.\n중요한 변경 사항의 경우 이메일로도 안내해 드립니다.',
        ),
        SizedBox(height: 40),
        _LegalFooter(company: 'HeartLink 개인정보 보호팀'),
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 6),
        Text(lastUpdated, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.7),
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
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '문의사항이 있으시면 $company(privacy@heartlink.app)로 연락해 주세요.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
