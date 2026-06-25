import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

import '../../../../l10n/app_localizations.dart';
class HomeDemoCardsSection extends StatelessWidget {
  final VoidCallback? onMarketTap;

  HomeDemoCardsSection({super.key, this.onMarketTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(),
          SizedBox(height: 12),
          _FeatureGrid(onMarketTap: onMarketTap),
          SizedBox(height: 10),
          _CompactReferralBanner(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Text(
          AppLocalizations.of(context).platformFeatures,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Spacer(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2×2 feature grid
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  final VoidCallback? onMarketTap;

  _FeatureGrid({this.onMarketTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: [
        _FeatureTile(
          icon: Icons.gavel_rounded,
          label: AppLocalizations.of(context).auctionSystem,
          subtitle: AppLocalizations.of(context).auctionSystemSub,
          color: AppColors.blue,
          bg: AppColors.blueLight,
        ),
        _FeatureTile(
          icon: Icons.shield_rounded,
          label: AppLocalizations.of(context).ownershipRecord,
          subtitle: AppLocalizations.of(context).ownershipRecordProtected,
          color: AppColors.primaryDark,
          bg: AppColors.primaryLight,
        ),
        _FeatureTile(
          icon: Icons.storefront_rounded,
          label: AppLocalizations.of(context).market,
          subtitle: AppLocalizations.of(context).marketSubtitle,
          color: AppColors.orange,
          bg: AppColors.orangeLight,
          onTap: onMarketTap,
        ),
        _FeatureTile(
          icon: Icons.bolt_rounded,
          label: AppLocalizations.of(context).pointsAndLoyalty,
          subtitle: AppLocalizations.of(context).pointsAndLoyaltySub,
          color: AppColors.primary,
          bg: AppColors.primaryLight,
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bg;
  final VoidCallback? onTap;

  _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: onTap != null
            ? Border.all(color: color.withValues(alpha: 0.35), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact referral strip
// ─────────────────────────────────────────────────────────────────────────────
class _CompactReferralBanner extends StatefulWidget {
  _CompactReferralBanner();

  @override
  State<_CompactReferralBanner> createState() => _CompactReferralBannerState();
}

class _CompactReferralBannerState extends State<_CompactReferralBanner> {
  bool _copied = false;

  void _copy() {
    setState(() => _copied = true);
    Future.delayed(Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_add_rounded,
                color: AppColors.primary, size: 18),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).rewardsProgram,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppLocalizations.of(context).referralCodeHint,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: _copy,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    _copied ? AppColors.primaryLight : AppColors.inputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: _copied
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _copied ? AppLocalizations.of(context).copied : AppLocalizations.of(context).copy,
                    style: TextStyle(
                      fontSize: 11,
                      color: _copied
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_rounded,
                color: Color(0xFF25D366),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
