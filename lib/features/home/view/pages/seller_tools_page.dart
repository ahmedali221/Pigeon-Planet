import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../seller_products/view/pages/seller_products_page.dart';
import '../../model/seller_home_summary.dart';
import '../widgets/home_provider_features_section.dart';
import '../widgets/home_seller_demo_section.dart';
import '../widgets/home_seller_notifications_section.dart';

import '../../../../l10n/app_localizations.dart';
class SellerToolsPage extends StatelessWidget {
  final SellerHomeSummary? summary;

  SellerToolsPage({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 210,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: [StretchMode.zoomBackground],
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, color: Colors.white, size: 15),
                  SizedBox(width: 5),
                  Text(
                    'أدواتي ومميزاتي',
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
                  DecoratedBox(
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
                    top: -30,
                    left: -30,
                    child: _ToolsDecorCircle(size: 160, opacity: 0.07),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -20,
                    child: _ToolsDecorCircle(size: 130, opacity: 0.06),
                  ),
                  Positioned(
                    top: 50,
                    left: 90,
                    child: _ToolsDecorCircle(size: 60, opacity: 0.04),
                  ),
                  // Content — supplementary only (no title text)
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 6, 20, 52),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon box
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(Icons.tune_rounded,
                                    color: Colors.white, size: 24),
                              ),
                              SizedBox(width: 12),
                              // Tagline
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مركز التحكم',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'إشعاراتك • مميزاتك • أدواتك في مكان واحد',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Section chips
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _ToolsChip(
                                icon: Icons.notifications_rounded,
                                label: AppLocalizations.of(context).notifications,
                                count: s?.notificationsNewCount ?? 0,
                              ),
                              _ToolsChip(
                                icon: Icons.verified_rounded,
                                label: 'المميزات',
                              ),
                              _ToolsChip(
                                icon: Icons.gavel_rounded,
                                label: 'الأدوات',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                _MyProductsCard(),
                HomeSellerNotificationsSection(summary: summary),
                HomeProviderFeaturesSection(summary: summary),
                HomeSellerDemoSection(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsDecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  _ToolsDecorCircle({required this.size, required this.opacity});

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

class _ToolsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  _ToolsChip({required this.icon, required this.label, this.count = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
          if (count > 0) ...[
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── My Products entry card ────────────────────────────────────────────────────

class _MyProductsCard extends StatelessWidget {
  _MyProductsCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SellerProductsPage()),
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          // RTL: icon box rightmost, text middle, arrow leftmost
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: AppColors.primary, size: 24),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'منتجاتي',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'إضافة وإدارة منتجاتك في المتجر',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
