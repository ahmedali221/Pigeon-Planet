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

class HomeSellerMetricsSection extends StatelessWidget {
  final SellerHomeSummary? summary;
  final int myAuctionsCount;
  final int myBirdsCount;
  final String? displayName;
  final bool showSellerTools;

  const HomeSellerMetricsSection({
    super.key,
    this.summary,
    this.myAuctionsCount = 0,
    this.myBirdsCount = 0,
    this.displayName,
    this.showSellerTools = true,
  });

  String get _greeting {
    final n = summary?.nickname.trim().isNotEmpty == true
        ? summary!.nickname.trim()
        : (displayName ?? '').trim();
    if (n.isEmpty) return 'مرحباً بعودتك! 👋';
    return 'مرحباً $n 👋';
  }

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final pkg = s?.packageLabel ?? 'بدون باقة';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
                          _greeting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'الباقة الحالية',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
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
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pkg,
                            style: const TextStyle(
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
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SellerStatsPage(summary: s),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'عرض الإحصائيات الكاملة',
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

          const SizedBox(height: 12),

          // ── Listings card ─────────────────────────────────────────────────
          _ListingsCard(
            auctionsCount: myAuctionsCount,
            birdsCount: myBirdsCount,
            onAuctionsTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerMyAuctionsPage()),
              );
              if (context.mounted) {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              }
            },
            onBirdsTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerMyBirdsPage()),
              );
              if (context.mounted) {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              }
            },
            onStoreTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellerProductsPage()),
            ),
          ),

          const SizedBox(height: 10),

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
            const SizedBox(height: 10),

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

  const _ListingsCard({
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
            label: 'مزاداتي',
            onTap: onAuctionsTap,
            isFirst: true,
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _ListingRow(
            icon: Icons.flutter_dash,
            iconColor: AppColors.orange,
            iconBg: AppColors.orangeLight,
            count: birdsCount,
            label: 'طيوري',
            onTap: onBirdsTap,
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          _ListingRow(
            icon: Icons.storefront_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            label: 'إضافة منتج للمتجر',
            subtitle: 'علف، أدوية، مستلزمات',
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

  const _ListingRow({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(13) : Radius.zero,
            bottom: isLast ? const Radius.circular(13) : Radius.zero,
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
            const SizedBox(width: 12),
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
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
            ),
            const Icon(
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

  const _EngagementRow({required this.summary});

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
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (s.followersCount > 0)
            _StatCell(
              icon: Icons.people_rounded,
              color: AppColors.blue,
              value: '${s.followersCount}',
              label: 'متابع',
            ),
          if (s.followersCount > 0 && s.totalBidsReceived > 0)
            const _VertDivider(),
          if (s.totalBidsReceived > 0)
            _StatCell(
              icon: Icons.gavel_rounded,
              color: AppColors.primary,
              value: '${s.totalBidsReceived}',
              label: 'مزايدة',
            ),
          if (s.totalBidsReceived > 0 && rating != null)
            const _VertDivider(),
          if (rating != null)
            _StatCell(
              icon: Icons.star_rounded,
              color: AppColors.orange,
              value: rating.toStringAsFixed(1),
              label: 'تقييم',
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

  const _StatCell({
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
        const SizedBox(height: 4),
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
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

// ── Tools nav tile ────────────────────────────────────────────────────────────

class _ToolsNavTile extends StatelessWidget {
  final int notifCount;
  final VoidCallback onTap;

  const _ToolsNavTile({required this.notifCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أدواتي ومميزاتي',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'إشعارات · متطلبات النشر · أدوات متقدمة',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (notifCount > 0)
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$notifCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(
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
