import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_home_summary.dart';
import '../../viewmodel/home_bloc.dart';
import '../pages/seller_my_birds_page.dart';
import '../pages/seller_my_auctions_page.dart';
import '../pages/seller_stats_page.dart';
import '../pages/seller_tools_page.dart';
import '../../../seller_products/view/pages/seller_products_page.dart';

import '../../../../l10n/app_localizations.dart';
class HomeSellerMetricsSection extends StatelessWidget {
  final SellerHomeSummary? summary;
  final int myAuctionsCount;
  final int myBirdsCount;
  final String? displayName;
  final bool showSellerTools;

  HomeSellerMetricsSection({
    super.key,
    this.summary,
    this.myAuctionsCount = 0,
    this.myBirdsCount = 0,
    this.displayName,
    this.showSellerTools = true,
  });

  String _greeting(AppLocalizations l) {
    final n = summary?.nickname.trim().isNotEmpty == true
        ? summary!.nickname.trim()
        : (displayName ?? '').trim();
    if (n.isEmpty) return l.welcomeBackGeneric;
    return l.welcomeWithName(n);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = summary;
    final pkg = s?.packageLabel ?? l.noPackage;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(l),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          AppLocalizations.of(context).currentPackage,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            pkg,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellerStatsPage(summary: s),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          l.viewAllStats,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // ── Listings card ─────────────────────────────────────────────────
          _ListingsCard(
            auctionsCount: myAuctionsCount,
            birdsCount: myBirdsCount,
            onAuctionsTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SellerMyAuctionsPage()),
              );
              if (context.mounted) {
                context.read<HomeBloc>().add(HomeRefreshRequested());
              }
            },
            onBirdsTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SellerMyBirdsPage()),
              );
              if (context.mounted) {
                context.read<HomeBloc>().add(HomeRefreshRequested());
              }
            },
            onStoreTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SellerProductsPage()),
            ),
          ),

          SizedBox(height: 10),

          // ── Engagement / trust quick-stats ────────────────────────────────
          if (s != null &&
              (s.followersCount > 0 ||
                  s.totalBidsReceived > 0 ||
                  s.averageRating != null))
            _EngagementRow(summary: s),

          if (s != null &&
              (s.followersCount > 0 ||
                  s.totalBidsReceived > 0 ||
                  s.averageRating != null))
            SizedBox(height: 10),

          // ── Tools tile ────────────────────────────────────────────────────
          _ToolsNavTile(
            notifCount: s?.notificationsNewCount ?? 0,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SellerToolsPage(summary: s)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Listings card (auctions + birds + store) ──────────────────────────────────

class _ListingsCard extends StatelessWidget {
  final int auctionsCount;
  final int birdsCount;
  final VoidCallback onAuctionsTap;
  final VoidCallback onBirdsTap;
  final VoidCallback onStoreTap;

  _ListingsCard({
    required this.auctionsCount,
    required this.birdsCount,
    required this.onAuctionsTap,
    required this.onBirdsTap,
    required this.onStoreTap,
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
          _ListingRow(
            icon: Icons.gavel_rounded,
            iconColor: AppColors.blue,
            iconBg: AppColors.blueLight,
            count: auctionsCount,
            label: AppLocalizations.of(context).myAuctions,
            onTap: onAuctionsTap,
            isFirst: true,
          ),
          Divider(height: 1, indent: 14, endIndent: 14),
          _ListingRow(
            icon: Icons.flutter_dash,
            iconColor: AppColors.orange,
            iconBg: AppColors.orangeLight,
            count: birdsCount,
            label: AppLocalizations.of(context).myBirds,
            onTap: onBirdsTap,
          ),
          Divider(height: 1, indent: 14, endIndent: 14),
          _ListingRow(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            label: AppLocalizations.of(context).addProductToStore,
            subtitle: AppLocalizations.of(context).marketSubtitle,
            onTap: onStoreTap,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int? count;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  _ListingRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.count,
    this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? Radius.circular(13) : Radius.zero,
            bottom: isLast ? Radius.circular(13) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 12),
            Expanded(
              child: count != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Engagement / trust quick-stats row ───────────────────────────────────────

class _EngagementRow extends StatelessWidget {
  final SellerHomeSummary summary;

  _EngagementRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final rating = s.averageRating;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (s.followersCount > 0)
            _StatCell(
              icon: Icons.people_rounded,
              color: AppColors.blue,
              value: '${s.followersCount}',
              label: AppLocalizations.of(context).followers,
            ),
          if (s.followersCount > 0 && s.totalBidsReceived > 0)
            _VertDivider(),
          if (s.totalBidsReceived > 0)
            _StatCell(
              icon: Icons.gavel_rounded,
              color: AppColors.primary,
              value: '${s.totalBidsReceived}',
              label: AppLocalizations.of(context).bidsLabel,
            ),
          if (s.totalBidsReceived > 0 && rating != null)
            _VertDivider(),
          if (rating != null)
            _StatCell(
              icon: Icons.star_rounded,
              color: AppColors.orange,
              value: rating.toStringAsFixed(1),
              label: AppLocalizations.of(context).ratingLabel,
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  _StatCell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

// ── Tools nav tile ────────────────────────────────────────────────────────────

class _ToolsNavTile extends StatelessWidget {
  final int notifCount;
  final VoidCallback onTap;

  _ToolsNavTile({required this.notifCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).myToolsAndFeatures,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).toolsPageSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Spacer(),
            if (notifCount > 0)
              Container(
                margin: EdgeInsetsDirectional.only(end: 8),
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$notifCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
