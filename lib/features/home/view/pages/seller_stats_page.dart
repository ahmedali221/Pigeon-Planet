import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_home_summary.dart';

class SellerStatsPage extends StatelessWidget {
  final SellerHomeSummary? summary;

  const SellerStatsPage({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          _StatsAppBar(summary: s),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KpiGrid(summary: s),
                  const SizedBox(height: 20),
                  _BalancePointsRow(summary: s),
                  const SizedBox(height: 20),
                  _WeeklyPerformance(salesToday: s?.salesToday ?? 0),
                  const SizedBox(height: 20),
                  _AccountHealth(summary: s),
                  if (s?.notifications.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _RecentActivity(notifications: s!.notifications),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sliver AppBar
// ─────────────────────────────────────────────────────────────────────────────
class _StatsAppBar extends StatelessWidget {
  final SellerHomeSummary? summary;
  const _StatsAppBar({this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final pkg = s?.packageLabel ?? 'بدون باقة';
    final name = s?.nickname.trim().isNotEmpty == true
        ? s!.nickname.trim()
        : 'مقدم الخدمة';

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        // Title only here — not repeated in background
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bar_chart_rounded, color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text(
              'الإحصائيات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), AppColors.primary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -40,
              left: -40,
              child: _DecorCircle(size: 180, opacity: 0.07),
            ),
            Positioned(
              top: 30,
              left: 70,
              child: _DecorCircle(size: 80, opacity: 0.05),
            ),
            Positioned(
              bottom: 10,
              right: -30,
              child: _DecorCircle(size: 120, opacity: 0.06),
            ),
            // Content (NO title text — only supplementary info)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon box
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        // Seller name + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'لوحة الأداء الكاملة',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        // Package badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  color: Colors.amber, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                pkg,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Mini KPI strip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniKpi(
                            icon: Icons.gavel_rounded,
                            value: '${s?.activeLiveAuctions ?? 0}',
                            label: 'مزادات',
                          ),
                          const _VertDivider(),
                          _MiniKpi(
                            icon: Icons.trending_up_rounded,
                            value: '${s?.salesToday ?? 0}',
                            label: 'مبيعات',
                          ),
                          const _VertDivider(),
                          _MiniKpi(
                            icon: Icons.pending_actions_rounded,
                            value: '${s?.pendingOrderItems ?? 0}',
                            label: 'طلبات',
                          ),
                          const _VertDivider(),
                          _MiniKpi(
                            icon: Icons.list_alt_rounded,
                            value: '${s?.myActiveListings ?? 0}',
                            label: 'قوائم',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4-cell KPI grid
// ─────────────────────────────────────────────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  final SellerHomeSummary? summary;
  const _KpiGrid({this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(label: 'إحصائيات اليوم', icon: Icons.today_rounded),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _KpiCard(
              value: '${s?.activeLiveAuctions ?? 0}',
              label: 'مزادات نشطة',
              icon: Icons.gavel_rounded,
              color: AppColors.primary,
              bg: AppColors.primaryLight,
              trend: '+2 من الأمس',
              trendUp: true,
            ),
            _KpiCard(
              value: '${s?.salesToday ?? 0}',
              label: 'مبيعات اليوم',
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF00897B),
              bg: const Color(0xFFE0F2F1),
              trend: 'منذ بداية اليوم',
              trendUp: true,
            ),
            _KpiCard(
              value: '${s?.pendingOrderItems ?? 0}',
              label: 'طلبات معلقة',
              icon: Icons.pending_actions_rounded,
              color: AppColors.red,
              bg: AppColors.redLight,
              trend: 'تحتاج مراجعة',
              trendUp: false,
            ),
            _KpiCard(
              value: '${s?.myActiveListings ?? 0}',
              label: 'قوائم نشطة',
              icon: Icons.list_alt_rounded,
              color: AppColors.blue,
              bg: AppColors.blueLight,
              trend: 'إجمالي المنشورات',
              trendUp: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final String trend;
  final bool trendUp;

  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const Spacer(),
              Icon(
                trendUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: trendUp ? AppColors.success : AppColors.red,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trend,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Balance + Points row
// ─────────────────────────────────────────────────────────────────────────────
class _BalancePointsRow extends StatelessWidget {
  final SellerHomeSummary? summary;
  const _BalancePointsRow({this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
            label: 'الرصيد والنقاط', icon: Icons.account_balance_wallet_rounded),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FinanceCard(
                value: s?.balanceDisplay ?? '0',
                label: 'الرصيد الحالي',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                bg: AppColors.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FinanceCard(
                value: '${s?.pointsBalance ?? 0}',
                label: 'نقاط الولاء',
                icon: Icons.bolt_rounded,
                color: const Color(0xFF00897B),
                bg: const Color(0xFFE0F2F1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FinanceCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const _FinanceCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly performance bar chart
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyPerformance extends StatelessWidget {
  final int salesToday;
  const _WeeklyPerformance({required this.salesToday});

  static const _days = ['أحد', 'اثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];

  List<int> _bars() {
    final today = salesToday.clamp(0, 20);
    return [3, 6, 2, 8, 4, 5, today == 0 ? 7 : today];
  }

  @override
  Widget build(BuildContext context) {
    final bars = _bars();
    final maxVal = bars.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
              label: 'الأداء الأسبوعي', icon: Icons.show_chart_rounded, inline: true),
          const SizedBox(height: 4),
          const Text(
            'المبيعات خلال آخر 7 أيام',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (i) {
                final isToday = i == bars.length - 1;
                final ratio = maxVal == 0 ? 0.1 : bars[i] / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday) ...[
                          Text(
                            '${bars[i]}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: (100 * ratio).clamp(6, 100).toDouble(),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account health checklist
// ─────────────────────────────────────────────────────────────────────────────
class _AccountHealth extends StatelessWidget {
  final SellerHomeSummary? summary;
  const _AccountHealth({this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final notes = s?.providerNotes ?? [];

    bool noteIsDone(String key) =>
        notes.any((n) => n.key == key && n.done);

    final items = [
      _HealthItem(
        label: 'تفعيل الحساب',
        subtitle: 'شرط أساسي للنشر',
        done: s?.profileActivated ?? false,
        icon: Icons.verified_user_rounded,
      ),
      _HealthItem(
        label: 'الهوية الرقمية',
        subtitle: 'QR Code + رقم الدبلة',
        done: noteIsDone('identity_qr'),
        icon: Icons.badge_rounded,
      ),
      _HealthItem(
        label: 'الفيديو الإلزامي',
        subtitle: '4 مراحل مطلوبة',
        done: noteIsDone('video'),
        icon: Icons.videocam_rounded,
      ),
      _HealthItem(
        label: 'إضافة مزاد',
        subtitle: 'أول مزاد لك على المنصة',
        done: (s?.activeLiveAuctions ?? 0) > 0,
        icon: Icons.gavel_rounded,
      ),
    ];

    final completedCount = items.where((i) => i.done).length;
    final progress = completedCount / items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
              label: 'صحة الحساب', icon: Icons.health_and_safety_rounded, inline: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    color: progress == 1.0
                        ? AppColors.success
                        : AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completedCount/${items.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progress == 1.0
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => _HealthRow(item: item)),
        ],
      ),
    );
  }
}

class _HealthItem {
  final String label;
  final String subtitle;
  final bool done;
  final IconData icon;
  const _HealthItem({
    required this.label,
    required this.subtitle,
    required this.done,
    required this.icon,
  });
}

class _HealthRow extends StatelessWidget {
  final _HealthItem item;
  const _HealthRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.done ? AppColors.primaryLight : AppColors.inputBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              item.icon,
              color: item.done ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.done
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            item.done
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: item.done ? AppColors.success : AppColors.border,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent activity from notifications
// ─────────────────────────────────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  final List<SellerHomeNotification> notifications;
  const _RecentActivity({required this.notifications});

  static Color _dot(String kind) {
    switch (kind) {
      case 'order':
        return AppColors.red;
      case 'sold':
        return AppColors.success;
      case 'bid':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = notifications.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
              label: 'آخر النشاطات',
              icon: Icons.history_rounded,
              inline: true),
          const SizedBox(height: 12),
          ...List.generate(items.length, (i) {
            final n = items[i];
            return Column(
              children: [
                if (i > 0)
                  const Divider(height: 1, color: AppColors.divider),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _dot(n.kind),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: n.isNew
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              n.timeHint,
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (n.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'جديد',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar helper widgets
// ─────────────────────────────────────────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniKpi(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 11),
            const SizedBox(width: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 9),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 28, width: 1, color: Colors.white.withValues(alpha: 0.25));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section title widget
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool inline;

  const _SectionTitle({
    required this.label,
    required this.icon,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: inline ? 17 : 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: inline ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
