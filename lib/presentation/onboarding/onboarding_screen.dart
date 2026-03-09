import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:connect_date/core/constants/app_constants.dart';
import 'package:connect_date/core/theme/app_theme.dart';
import 'package:connect_date/data/models/profile.dart';
import 'package:connect_date/data/repositories/profile_repository.dart';
import 'package:connect_date/domain/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 0 – Name & Age
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 1 – Gender & Looking for
  String _gender = '';
  String _lookingFor = '';

  // Step 2 – City & Bio
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 3 – Interests
  final Set<String> _selectedInterests = {};

  // Step 4 – Profile prompts
  final List<Map<String, String>> _prompts = [
    {'question': '나의 완벽한 주말은?', 'answer': ''},
    {'question': '내가 가장 좋아하는 것은?', 'answer': ''},
    {'question': '나에 대한 재미있는 사실은?', 'answer': ''},
  ];

  final List<TextEditingController> _promptControllers = List.generate(3, (_) => TextEditingController());

  static const int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    for (final c in _promptControllers) c.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        final age = int.tryParse(_ageController.text);
        if (_nameController.text.trim().isEmpty) {
          _showSnack('이름을 입력해주세요');
          return false;
        }
        if (age == null || age < AppConstants.minAge) {
          _showSnack('만 18세 이상만 가입 가능합니다');
          return false;
        }
        return true;
      case 1:
        if (_gender.isEmpty) {
          _showSnack('성별을 선택해주세요');
          return false;
        }
        if (_lookingFor.isEmpty) {
          _showSnack('원하는 상대를 선택해주세요');
          return false;
        }
        return true;
      case 2:
        if (_cityController.text.trim().isEmpty) {
          _showSnack('도시를 입력해주세요');
          return false;
        }
        return true;
      case 3:
        if (_selectedInterests.length < 3) {
          _showSnack('관심사를 최소 3개 선택해주세요');
          return false;
        }
        return true;
      case 4:
        return true;
      default:
        return true;
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _nextStep() async {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await _submitProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('로그인이 필요합니다');

      final promptsList = <Map<String, String>>[];
      for (int i = 0; i < _prompts.length; i++) {
        final answer = _promptControllers[i].text.trim();
        if (answer.isNotEmpty) {
          promptsList.add({
            'question': _prompts[i]['question']!,
            'answer': answer,
          });
        }
      }

      final profile = Profile(
        id: const Uuid().v4(),
        userId: user.id,
        displayName: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _gender,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        city: _cityController.text.trim(),
        interests: _selectedInterests.toList(),
        photos: [],
        lookingFor: _lookingFor,
        onboardingComplete: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ProfileRepository();
      await repo.updateProfile(profile);

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      _showSnack('프로필 저장 중 오류가 발생했습니다: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep0(),
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['기본 정보', '나는 어떤 사람?', '나의 위치', '관심사', '나를 표현해요'];
    final subtitles = [
      '이름과 나이를 알려주세요',
      '성별과 원하는 상대를 선택해주세요',
      '어디에 사시나요?',
      '관심사를 3개 이상 선택해주세요',
      '자신을 소개하는 문장을 써주세요 (선택)',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B8A), AppTheme.primaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'HeartLink',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            titles[_currentStep],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ).animate(key: ValueKey('title$_currentStep')).fadeIn(duration: 300.ms),
          const SizedBox(height: 6),
          Text(
            subtitles[_currentStep],
            style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ).animate(key: ValueKey('sub$_currentStep')).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentStep ? AppTheme.primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: '이름 (닉네임)',
              prefixIcon: Icon(Icons.person_outline),
              hintText: '홍길동',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '나이',
              prefixIcon: Icon(Icons.cake_outlined),
              hintText: '만 나이를 입력해주세요',
              suffixText: '세',
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '만 18세 이상만 가입할 수 있습니다.\n나이는 가입 후 변경할 수 없습니다.',
                    style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final genders = ['남성', '여성', '기타'];
    final lookingForOptions = ['남성', '여성', '모두'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('나의 성별', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: genders.map((g) {
              final selected = _gender == g;
              return _buildChoiceChip(label: g, selected: selected, onSelected: (_) {
                setState(() => _gender = g);
              });
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text('원하는 상대', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: lookingForOptions.map((opt) {
              final selected = _lookingFor == opt;
              return _buildChoiceChip(label: opt, selected: selected, onSelected: (_) {
                setState(() => _lookingFor = opt);
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          TextFormField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: '도시',
              prefixIcon: Icon(Icons.location_city_outlined),
              hintText: '예: 서울, 부산, 인천',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: '자기 소개 (선택)',
              hintText: '간단하게 자신을 소개해보세요!',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택: ${_selectedInterests.length} / 최소 3개',
            style: TextStyle(
              fontSize: 14,
              color: _selectedInterests.length >= 3
                  ? AppTheme.successColor
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.interestOptions.map((interest) {
              final selected = _selectedInterests.contains(interest);
              return _buildInterestChip(label: interest, selected: selected, onTap: () {
                setState(() {
                  if (selected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: List.generate(_prompts.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _prompts[i]['question']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _promptControllers[i],
                  maxLines: 2,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    hintText: '자유롭게 답변해주세요...',
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Widget _buildInterestChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(50),
          boxShadow: selected
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    final isLastStep = _currentStep == _totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _prevStep,
                child: const Text('이전'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(isLastStep ? '완료' : '다음'),
            ),
          ),
        ],
      ),
    );
  }
}
