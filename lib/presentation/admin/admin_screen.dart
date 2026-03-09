import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:connect_date/core/theme/app_theme.dart';

// Admin stats data class
class _AdminStats {
  final int totalUsers;
  final int totalMatches;
  final int totalMessages;
  final int totalReports;

  const _AdminStats({
    required this.totalUsers,
    required this.totalMatches,
    required this.totalMessages,
    required this.totalReports,
  });
}

// Report data class
class _Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;

  const _Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

final _adminStatsProvider = FutureProvider<_AdminStats>((ref) async {
  final client = Supabase.instance.client;
  try {
    final users = await client.from('profiles').select('id');
    final matches = await client.from('matches').select('id');
    final messages = await client.from('messages').select('id');
    final reports = await client.from('reports').select('id');

    return _AdminStats(
      totalUsers: (users as List).length,
      totalMatches: (matches as List).length,
      totalMessages: (messages as List).length,
      totalReports: (reports as List).length,
    );
  } catch (_) {
    return const _AdminStats(totalUsers: 0, totalMatches: 0, totalMessages: 0, totalReports: 0);
  }
});

final _reportsProvider = FutureProvider<List<_Report>>((ref) async {
  final client = Supabase.instance.client;
  try {
    final data = await client
        .from('reports')
        .select()
        .order('created_at', ascending: false)
        .limit(50);

    final rows = data as List<dynamic>;
    return rows.map((row) => _Report(
      id: row['id'] as String? ?? '',
      reporterId: row['reporter_id'] as String? ?? '',
      reporterName: row['reporter_name'] as String? ?? '알 수 없음',
      reportedUserId: row['reported_user_id'] as String? ?? '',
      reportedUserName: row['reported_user_name'] as String? ?? '알 수 없음',
      reason: row['reason'] as String? ?? '기타',
      description: row['description'] as String? ?? '',
      status: row['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
    )).toList();
  } catch (_) {
    return [];
  }
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_adminStatsProvider);
    final reportsAsync = ref.watch(_reportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('관리자 대시보드', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(_adminStatsProvider);
              ref.refresh(_reportsProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats section
            const Text(
              '통계',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (_, __) => const Text('통계를 불러올 수 없습니다', style: TextStyle(color: AppTheme.errorColor)),
              data: (stats) => _buildStatsGrid(stats),
            ),

            const SizedBox(height: 28),

            // Reports section
            Row(
              children: [
                const Text(
                  '신고 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                reportsAsync.when(
                  data: (reports) => Text(
                    '총 ${reports.length}건',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            reportsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
              error: (_, __) => const Center(child: Text('신고 목록을 불러올 수 없습니다')),
              data: (reports) {
                if (reports.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: AppTheme.successColor),
                          const SizedBox(height: 12),
                          const Text('처리되지 않은 신고가 없습니다', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: reports
                      .asMap()
                      .entries
                      .map((e) => _ReportCard(report: e.value, index: e.key, ref: ref))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(_AdminStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.people,
          label: '전체 사용자',
          value: stats.totalUsers,
          color: const Color(0xFF3B82F6),
        ).animate().fadeIn(delay: 100.ms),
        _StatCard(
          icon: Icons.favorite,
          label: '총 매칭',
          value: stats.totalMatches,
          color: AppTheme.primaryColor,
        ).animate().fadeIn(delay: 150.ms),
        _StatCard(
          icon: Icons.chat_bubble,
          label: '총 메시지',
          value: stats.totalMessages,
          color: AppTheme.successColor,
        ).animate().fadeIn(delay: 200.ms),
        _StatCard(
          icon: Icons.flag,
          label: '신고 건수',
          value: stats.totalReports,
          color: AppTheme.errorColor,
        ).animate().fadeIn(delay: 250.ms),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatNumber(value),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
              ),
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _ReportCard extends StatefulWidget {
  final _Report report;
  final int index;
  final WidgetRef ref;

  const _ReportCard({required this.report, required this.index, required this.ref});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _isBlocking = false;

  Future<void> _blockUser() async {
    setState(() => _isBlocking = true);
    try {
      final client = Supabase.instance.client;
      // Update report status and block user
      await client.from('reports').update({'status': 'resolved'}).eq('id', widget.report.id);
      await client.from('profiles').update({'is_blocked': true}).eq('user_id', widget.report.reportedUserId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.report.reportedUserName} 사용자가 차단되었습니다'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      widget.ref.refresh(_reportsProvider);
      widget.ref.refresh(_adminStatsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('차단 실패: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isBlocking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.report.status == 'pending'
        ? AppTheme.warningColor
        : widget.report.status == 'resolved'
            ? AppTheme.successColor
            : AppTheme.errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.report.status == 'pending' ? '처리 대기' : '처리 완료',
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    widget.report.reason,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(widget.report.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reporter → Reported
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                      children: [
                        TextSpan(
                          text: widget.report.reporterName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const TextSpan(text: ' → '),
                        TextSpan(
                          text: widget.report.reportedUserName,
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.errorColor),
                        ),
                        const TextSpan(text: ' 신고'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (widget.report.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.report.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Block button
            if (widget.report.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isBlocking ? null : _blockUser,
                  icon: _isBlocking
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.block, size: 16),
                  label: Text(_isBlocking ? '처리 중...' : '사용자 차단'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * widget.index), duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
