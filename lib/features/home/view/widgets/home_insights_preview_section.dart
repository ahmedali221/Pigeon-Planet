import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../insights/view/pages/insights_page.dart';
import '../../../insights/viewmodel/insights_bloc.dart';

class HomeInsightsPreviewSection extends StatelessWidget {
  const HomeInsightsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (_) => sl<InsightsBloc>()..add(const InsightsStarted()),
      child: const _InsightsPreview(),
    );
  }
}

class _InsightsPreview extends StatelessWidget {
  const _InsightsPreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        final insights = state.insights;
        final isLoading =
            state.status == InsightsStatus.loading && insights == null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ──────────────────────────────────────────────
              Row(
                children: [
                  const Text(
                    'ملخص نشاطك',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InsightsPage()),
                    ),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Two preview cards ───────────────────────────────────────────
              if (isLoading)
                const _LoadingCards()
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _PreviewCard(
                        icon: Icons.gavel_rounded,
                        iconBg: AppColors.blueLight,
                        iconColor: AppColors.blue,
                        title: 'المزادات',
                        stats: [
                          _PreviewStat(
                            label: 'نشطة',
                            value:
                                '${insights?.auctionSummary.activeCount ?? '—'}',
                          ),
                          _PreviewStat(
                            label: 'إجمالي العروض',
                            value:
                                '${insights?.auctionSummary.totalBidsReceived ?? '—'}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PreviewCard(
                        icon: Icons.storefront_rounded,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        title: 'المتجر',
                        stats: [
                          _PreviewStat(
                            label: 'منتجات',
                            value:
                                '${insights?.marketSummary.activeListingsCount ?? '—'}',
                          ),
                          _PreviewStat(
                            label: 'طلبات معلقة',
                            value:
                                '${insights?.marketSummary.pendingOrderItemsCount ?? '—'}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ── View more button ──────────────────────────────────────────
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InsightsPage()),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'عرض كل الإحصائيات',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Preview card ──────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final List<_PreviewStat> stats;

  const _PreviewCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...stats.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      s.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PreviewStat {
  final String label;
  final String value;

  const _PreviewStat({required this.label, required this.value});
}

// ── Loading placeholder ───────────────────────────────────────────────────────

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: const _ShimmerCard()),
        const SizedBox(width: 10),
        Expanded(child: const _ShimmerCard()),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
