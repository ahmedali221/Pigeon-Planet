import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../viewmodel/insights_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class InsightsPage extends StatelessWidget {
  InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsBloc>(
      create: (_) => sl<InsightsBloc>()..add(InsightsStarted()),
      child: _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  _InsightsView();

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
                        .add(InsightsRefreshRequested()),
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
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.status == InsightsStatus.error && state.insights == null) {
      return _ErrorView(
        message: state.errorMessage,
        onRetry: () =>
            context.read<InsightsBloc>().add(InsightsRefreshRequested()),
      );
    }
    final insights = state.insights;
    if (insights == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<InsightsBloc>().add(InsightsRefreshRequested()),
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionCard(
            icon: Icons.gavel_rounded,
            iconBg: AppColors.blueLight,
            iconColor: AppColors.blue,
            title: AppLocalizations.of(context).auctions,
            children: [
              _StatRow(
                  label: AppLocalizations.of(context).active2,
                  value: '${insights.auctionSummary.activeCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).closedAuctions,
                  value: '${insights.auctionSummary.closedCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).tnthyQryba,
                  value: '${insights.auctionSummary.endingSoonCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).totalOffersReceived,
                  value: '${insights.auctionSummary.totalBidsReceived}'),
              _StatRow(
                  label: AppLocalizations.of(context).uniqueBidders,
                  value: '${insights.auctionSummary.uniqueBiddersCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).completedSales,
                  value: '${insights.auctionSummary.soldItemsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).pendingPaymentRequests,
                  value: '${insights.auctionSummary.pendingPaymentCount}'),
            ],
          ),
          SizedBox(height: 12),
          _SectionCard(
            icon: Icons.storefront_rounded,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primary,
            title: AppLocalizations.of(context).market,
            children: [
              _StatRow(
                  label: AppLocalizations.of(context).listedProducts,
                  value: '${insights.marketSummary.activeListingsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).completedSales,
                  value: '${insights.marketSummary.soldItemsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).pendingOrders,
                  value: '${insights.marketSummary.pendingOrderItemsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).pendingPaymentRequests,
                  value: '${insights.marketSummary.pendingPaymentCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).lowStock,
                  value: '${insights.marketSummary.lowStockProductsCount}',
                  valueColor:
                      insights.marketSummary.lowStockProductsCount > 0
                          ? AppColors.orange
                          : null),
            ],
          ),
          SizedBox(height: 12),
          _SectionCard(
            icon: Icons.people_rounded,
            iconBg: Color(0xFFF3EEFE),
            iconColor: AppColors.purple,
            title: AppLocalizations.of(context).engagement,
            children: [
              _StatRow(
                  label: AppLocalizations.of(context).totalFollowers,
                  value: '${insights.engagementSummary.followersCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).newFollowers7Days,
                  value: '${insights.engagementSummary.newFollowers7d}'),
              _StatRow(
                  label: AppLocalizations.of(context).activeConversations,
                  value:
                      '${insights.engagementSummary.activeConversationsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).unreadMessages,
                  value: '${insights.engagementSummary.unreadMessages}'),
              _StatRow(
                  label: AppLocalizations.of(context).profileViews7Days,
                  value: '${insights.engagementSummary.profileViews7d}'),
              _StatRow(
                  label: AppLocalizations.of(context).auctionViews7Days,
                  value: '${insights.engagementSummary.auctionViews7d}'),
              _StatRow(
                  label: AppLocalizations.of(context).marketViews7Days,
                  value: '${insights.engagementSummary.marketItemViews7d}'),
            ],
          ),
          SizedBox(height: 12),
          _SectionCard(
            icon: Icons.verified_rounded,
            iconBg: Color(0xFFFFF8E1),
            iconColor: Color(0xFFF9A825),
            title: AppLocalizations.of(context).trust,
            children: [
              _StatRow(
                  label: AppLocalizations.of(context).averageRating,
                  value: insights.trustSummary.averageRating.toStringAsFixed(1)),
              _StatRow(
                  label: AppLocalizations.of(context).ratingsCount,
                  value: '${insights.trustSummary.ratingsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).newReviews7Days,
                  value: '${insights.trustSummary.recentReviewsCount7d}'),
              _StatRow(
                  label: AppLocalizations.of(context).badges,
                  value: '${insights.trustSummary.badgesCount}'),
            ],
          ),
          SizedBox(height: 12),
          _SectionCard(
            icon: Icons.workspace_premium_rounded,
            iconBg: AppColors.orangeLight,
            iconColor: AppColors.orange,
            title: AppLocalizations.of(context).package,
            children: [
              _StatRow(
                  label: AppLocalizations.of(context).currentPackage,
                  value: insights.packageSummary.displayName),
              if (insights.packageSummary.activePackageId != null)
                _StatRow(
                    label: AppLocalizations.of(context).packageNumber,
                    value: '${insights.packageSummary.activePackageId}'),
              _StatRow(
                  label: AppLocalizations.of(context).subscriptionStatus,
                  value:
                      insights.packageSummary.isActive ? AppLocalizations.of(context).statusActive : AppLocalizations.of(context).inactive,
                  valueColor: insights.packageSummary.isActive
                      ? AppColors.success
                      : AppColors.error),
              if (insights.packageSummary.remainingAuctionQuota != null)
                _StatRow(
                    label: AppLocalizations.of(context).remainingAuctionQuota,
                    value: '${insights.packageSummary.remainingAuctionQuota}'),
              if (insights.packageSummary.remainingMarketQuota != null)
                _StatRow(
                    label: AppLocalizations.of(context).remainingMarketQuota,
                    value: '${insights.packageSummary.remainingMarketQuota}'),
              if (insights.packageSummary.activePackageRemainingPoints != null)
                _StatRow(
                    label: AppLocalizations.of(context).remainingPackagePoints,
                    value:
                        '${insights.packageSummary.activePackageRemainingPoints}'),
              _StatRow(
                  label: AppLocalizations.of(context).promotedAuctions,
                  value: '${insights.packageSummary.promotedAuctionsCount}'),
              _StatRow(
                  label: AppLocalizations.of(context).promotedProducts,
                  value: '${insights.packageSummary.promotedMarketCount}'),
              if (insights.packageSummary.packageExpiryDate != null)
                _StatRow(
                    label: AppLocalizations.of(context).packageExpiryDate,
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

  _InsightsHeader({required this.onBack, this.onRefresh});

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
            child: Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text(
                AppLocalizations.of(context).myInsights,
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
              icon: Icon(Icons.refresh_rounded, color: Colors.white),
            )
          else
            SizedBox(width: 48),
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

  _SectionCard({
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
            padding: EdgeInsets.fromLTRB(14, 14, 14, 10),
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
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
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

  _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
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

  _ErrorView({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 12),
            Text(
              message ?? AppLocalizations.of(context).insightsLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
