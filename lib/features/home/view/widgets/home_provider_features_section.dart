import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_home_summary.dart';
import '../../../../l10n/app_localizations.dart';

class HomeProviderFeaturesSection extends StatelessWidget {
  final SellerHomeSummary? summary;

  const HomeProviderFeaturesSection({super.key, this.summary});

  static Color _color(String accent) {
    switch (accent) {
      case 'purple':
        return AppColors.purple;
      case 'red':
        return AppColors.red;
      case 'orange':
        return AppColors.orange;
      case 'primary':
      default:
        return AppColors.primary;
    }
  }

  static Color _light(String accent) {
    switch (accent) {
      case 'purple':
        return AppColors.purpleLight;
      case 'red':
        return AppColors.redLight;
      case 'orange':
        return AppColors.orangeLight;
      case 'primary':
      default:
        return AppColors.primaryLight;
    }
  }

  static IconData _trailing(String accent, bool done) {
    if (done) return Icons.check_circle_rounded;
    switch (accent) {
      case 'purple':
        return Icons.qr_code_2_rounded;
      case 'red':
        return Icons.play_circle_rounded;
      case 'orange':
        return Icons.hourglass_top_rounded;
      case 'primary':
      default:
        return Icons.add_box_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = summary?.providerNotes ?? const <SellerProviderNote>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded,
                  color: AppColors.purple, size: 18),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).providerFeatures,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
            ],
          ),

          const SizedBox(height: 10),

          if (notes.isEmpty)
            const _FallbackTiles()
          else
            ...notes.expand((n) => [
                  _FeatureTile(
                    icon: _iconForKey(n.key),
                    title: n.title,
                    subtitle: n.subtitle,
                    color: _color(n.accent),
                    lightColor: _light(n.accent),
                    trailingIcon: _trailing(n.accent, n.done),
                    done: n.done,
                  ),
                  const SizedBox(height: 8),
                ]),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDD835)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    summary?.profileActivated == false
                        ? AppLocalizations.of(context).sellerActivationRequired
                        : AppLocalizations.of(context).digitalIdVideoRequired,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF795548)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('💡', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForKey(String key) {
    switch (key) {
      case 'activation':
        return Icons.verified_user_rounded;
      case 'identity_qr':
        return Icons.badge_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'auction_identity':
      default:
        return Icons.add_box_rounded;
    }
  }
}

/// Static tiles when API returns no provider_notes (should not happen).
class _FallbackTiles extends StatelessWidget {
  const _FallbackTiles();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        _FeatureTile(
          icon: Icons.add_box_rounded,
          title: l.addAuctionWithDigitalId,
          subtitle: l.addAuctionWithDigitalIdSub,
          color: AppColors.primary,
          lightColor: AppColors.primaryLight,
          trailingIcon: Icons.check_circle_rounded,
          done: false,
        ),
        SizedBox(height: 8),
        _FeatureTile(
          icon: Icons.badge_rounded,
          title: l.viewDigitalId,
          subtitle: l.viewDigitalIdSub,
          color: AppColors.purple,
          lightColor: AppColors.purpleLight,
          trailingIcon: Icons.qr_code_2_rounded,
          done: false,
        ),
        SizedBox(height: 8),
        _FeatureTile(
          icon: Icons.videocam_rounded,
          title: l.mandatoryVideo,
          subtitle: l.mandatoryVideoSub,
          color: AppColors.red,
          lightColor: AppColors.redLight,
          trailingIcon: Icons.play_circle_rounded,
          done: false,
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color lightColor;
  final IconData trailingIcon;
  final bool done;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lightColor,
    required this.trailingIcon,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? color.withValues(alpha: 0.45) : AppColors.border,
          width: done ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(trailingIcon, color: color, size: 24),
        ],
      ),
    );
  }
}
