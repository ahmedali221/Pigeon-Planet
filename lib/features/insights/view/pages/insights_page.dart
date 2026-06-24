import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../viewmodel/insights_bloc.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (_) => sl<InsightsBloc>()..add(const InsightsStarted()),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Column(
            children: [
              _InsightsHeader(
                onBack: () => Navigator.pop(context),
                onRefresh: state.status == InsightsStatus.loading
                    ? null
                    : () => context
                        .read<InsightsBloc>()
                        .add(const InsightsRefreshRequested()),
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, InsightsState state) {
    if (state.status == InsightsStatus.loading && state.insights == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.status == InsightsStatus.error && state.insights == null) {
      return _ErrorView(
        message: state.errorMessage,
        onRetry: () =>
            context.read<InsightsBloc>().add(const InsightsRefreshRequested()),
      );
    }
    final insights = state.insights;
    if (insights == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<InsightsBloc>().add(const InsightsRefreshRequested()),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionCard(
            icon: Icons.gavel_rounded,
            iconBg: AppColors.blueLight,
            iconColor: AppColors.blue,
            title: 'المزادات',
            children: [
              _StatRow(
                  label: 'مزادات نشطة',
                  value: '${insights.auctionSummary.activeCount}'),
              _StatRow(
                  label: 'مزادات مغلقة',
                  value: '${insights.auctionSummary.closedCount}'),
              _StatRow(
                  label: 'تنتهي قريباً',
                  value: '${insights.auctionSummary.endingSoonCount}'),
              _StatRow(
                  label: 'إجمالي العروض المستلمة',
                  value: '${insights.auctionSummary.totalBidsReceived}'),
              _StatRow(
                  label: 'مزايدون فريدون',
                  value: '${insights.auctionSummary.uniqueBiddersCount}'),
              _StatRow(
                  label: 'مبيعات مكتملة',
                  value: '${insights.auctionSummary.soldItemsCount}'),
              _StatRow(
                  label: 'طلبات دفع معلقة',
                  value: '${insights.auctionSummary.pendingPaymentCount}'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.storefront_rounded,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primary,
            title: 'المتجر',
            children: [
              _StatRow(
                  label: 'منتجات معروضة',
                  value: '${insights.marketSummary.activeListingsCount}'),
              _StatRow(
                  label: 'مبيعات مكتملة',
                  value: '${insights.marketSummary.soldItemsCount}'),
              _StatRow(
                  label: 'طلبات معلقة',
                  value: '${insights.marketSummary.pendingOrderItemsCount}'),
              _StatRow(
                  label: 'طلبات دفع معلقة',
                  value: '${insights.marketSummary.pendingPaymentCount}'),
              _StatRow(
                  label: 'مخزون منخفض',
                  value: '${insights.marketSummary.lowStockProductsCount}',
                  valueColor:
                      insights.marketSummary.lowStockProductsCount > 0
                          ? AppColors.orange
                          : null),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.people_rounded,
            iconBg: const Color(0xFFF3EEFE),
            iconColor: AppColors.purple,
            title: 'التفاعل',
            children: [
              _StatRow(
                  label: 'إجمالي المتابعين',
                  value: '${insights.engagementSummary.followersCount}'),
              _StatRow(
                  label: 'متابعون جدد (7 أيام)',
                  value: '${insights.engagementSummary.newFollowers7d}'),
              _StatRow(
                  label: 'محادثات نشطة',
                  value:
                      '${insights.engagementSummary.activeConversationsCount}'),
              _StatRow(
                  label: 'رسائل غير مقروءة',
                  value: '${insights.engagementSummary.unreadMessages}'),
              _StatRow(
                  label: 'مشاهدات الملف (7 أيام)',
                  value: '${insights.engagementSummary.profileViews7d}'),
              _StatRow(
                  label: 'مشاهدات المزادات (7 أيام)',
                  value: '${insights.engagementSummary.auctionViews7d}'),
              _StatRow(
                  label: 'مشاهدات المتجر (7 أيام)',
                  value: '${insights.engagementSummary.marketItemViews7d}'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.verified_rounded,
            iconBg: const Color(0xFFFFF8E1),
            iconColor: const Color(0xFFF9A825),
            title: 'الموثوقية',
            children: [
              _StatRow(
                  label: 'متوسط التقييم',
                  value: insights.trustSummary.averageRating.toStringAsFixed(1)),
              _StatRow(
                  label: 'عدد التقييمات',
                  value: '${insights.trustSummary.ratingsCount}'),
              _StatRow(
                  label: 'مراجعات جديدة (7 أيام)',
                  value: '${insights.trustSummary.recentReviewsCount7d}'),
              _StatRow(
                  label: 'الشارات',
                  value: '${insights.trustSummary.badgesCount}'),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.workspace_premium_rounded,
            iconBg: AppColors.orangeLight,
            iconColor: AppColors.orange,
            title: 'الباقة',
            children: [
              _StatRow(
                  label: 'الباقة الحالية',
                  value: insights.packageSummary.displayName),
              if (insights.packageSummary.activePackageId != null)
                _StatRow(
                    label: 'رقم الباقة',
                    value: '${insights.packageSummary.activePackageId}'),
              _StatRow(
                  label: 'حالة الاشتراك',
                  value:
                      insights.packageSummary.isActive ? 'نشط' : 'غير نشط',
                  valueColor: insights.packageSummary.isActive
                      ? AppColors.success
                      : AppColors.error),
              if (insights.packageSummary.remainingAuctionQuota != null)
                _StatRow(
                    label: 'حصة المزادات المتبقية',
                    value: '${insights.packageSummary.remainingAuctionQuota}'),
              if (insights.packageSummary.remainingMarketQuota != null)
                _StatRow(
                    label: 'حصة المتجر المتبقية',
                    value: '${insights.packageSummary.remainingMarketQuota}'),
              if (insights.packageSummary.activePackageRemainingPoints != null)
                _StatRow(
                    label: 'نقاط الباقة المتبقية',
                    value:
                        '${insights.packageSummary.activePackageRemainingPoints}'),
              _StatRow(
                  label: 'مزادات مروجة',
                  value: '${insights.packageSummary.promotedAuctionsCount}'),
              _StatRow(
                  label: 'منتجات مروجة',
                  value: '${insights.packageSummary.promotedMarketCount}'),
              if (insights.packageSummary.packageExpiryDate != null)
                _StatRow(
                    label: 'تاريخ انتهاء الباقة',
                    value: _formatDate(
                        insights.packageSummary.packageExpiryDate!)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

class _InsightsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onRefresh;

  const _InsightsHeader({required this.onBack, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: topPadding + 12,
        bottom: 14,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'إحصائياتي',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          ...children,
        ],
      ),
    );
  }
}

// ── Stat row ──────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorView({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message ?? 'فشل تحميل الإحصائيات',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
