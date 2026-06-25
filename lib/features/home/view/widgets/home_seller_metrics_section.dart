import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_home_summary.dart';
import '../pages/seller_stats_page.dart';

import '../../../../l10n/app_localizations.dart';

class HomeSellerMetricsSection extends StatelessWidget {
  final SellerHomeSummary? summary;
  final String? displayName;

  HomeSellerMetricsSection({
    super.key,
    this.summary,
    this.displayName,
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
                          l.currentPackage,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: Colors.white, size: 16),
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
                        Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Engagement / trust quick-stats ────────────────────────────────
          if (s != null &&
              (s.followersCount > 0 ||
                  s.totalBidsReceived > 0 ||
                  s.averageRating != null)) ...[
            SizedBox(height: 10),
            _EngagementRow(summary: s),
          ],
        ],
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
