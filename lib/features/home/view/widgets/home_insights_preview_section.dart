import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../../insights/view/pages/insights_page.dart';
import '../../../insights/viewmodel/insights_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class HomeInsightsPreviewSection extends StatelessWidget {
  HomeInsightsPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (_) => sl<InsightsBloc>()..add(InsightsStarted()),
      child: _InsightsPreview(),
    );
  }
}

class _InsightsPreview extends StatelessWidget {
  _InsightsPreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        final insights = state.insights;
        final isLoading =
            state.status == InsightsStatus.loading && insights == null;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ──────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).activitySummary,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => InsightsPage()),
                    ),
                    child: Text(
                      AppLocalizations.of(context).viewAll,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // ── Two preview cards ───────────────────────────────────────────
              if (isLoading)
                _LoadingCards()
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: _PreviewCard(
                        icon: Icons.gavel_rounded,
                        iconBg: AppColors.blueLight,
                        iconColor: AppColors.blue,
                        title: AppLocalizations.of(context).auctions,
                        stats: [
                          _PreviewStat(
                            label: AppLocalizations.of(context).statusActive,
                            value:
                                '${insights?.auctionSummary.activeCount ?? '—'}',
                          ),
                          _PreviewStat(
                            label: AppLocalizations.of(context).totalOffersReceived,
                            value:
                                '${insights?.auctionSummary.totalBidsReceived ?? '—'}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _PreviewCard(
                        icon: Icons.storefront_rounded,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        title: AppLocalizations.of(context).market,
                        stats: [
                          _PreviewStat(
                            label: AppLocalizations.of(context).products,
                            value:
                                '${insights?.marketSummary.activeListingsCount ?? '—'}',
                          ),
                          _PreviewStat(
                            label: AppLocalizations.of(context).pendingOrders,
                            value:
                                '${insights?.marketSummary.pendingOrderItemsCount ?? '—'}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ── View more button ──────────────────────────────────────────
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => InsightsPage()),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).viewAllStats,
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

  _PreviewCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
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
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...stats.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      s.value,
                      style: TextStyle(
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

  _PreviewStat({required this.label, required this.value});
}

// ── Loading placeholder ───────────────────────────────────────────────────────

class _LoadingCards extends StatelessWidget {
  _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ShimmerCard()),
        SizedBox(width: 10),
        Expanded(child: _ShimmerCard()),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  _ShimmerCard();

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
