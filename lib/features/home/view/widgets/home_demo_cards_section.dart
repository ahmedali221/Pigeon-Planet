import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeDemoCardsSection extends StatelessWidget {
  const HomeDemoCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(),
          SizedBox(height: 12),
          _FeatureGrid(),
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
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Text(
          'مميزات المنصة',
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
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: const [
        _FeatureTile(
          icon: Icons.gavel_rounded,
          label: 'نظام المزايدات',
          subtitle: 'مزايدة حية ومتقدمة',
          color: AppColors.blue,
          bg: AppColors.blueLight,
        ),
        _FeatureTile(
          icon: Icons.shield_rounded,
          label: 'سجل الملكية',
          subtitle: 'محمي وغير قابل للتلاعب',
          color: AppColors.primaryDark,
          bg: AppColors.primaryLight,
        ),
        _FeatureTile(
          icon: Icons.storefront_rounded,
          label: 'المتجر',
          subtitle: 'علف، أدوية، مستلزمات',
          color: AppColors.orange,
          bg: AppColors.orangeLight,
        ),
        _FeatureTile(
          icon: Icons.bolt_rounded,
          label: 'نقاط وولاء',
          subtitle: 'اكسب مع كل عملية',
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

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
          const SizedBox(width: 10),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Compact referral strip
// ─────────────────────────────────────────────────────────────────────────────
class _CompactReferralBanner extends StatefulWidget {
  const _CompactReferralBanner();

  @override
  State<_CompactReferralBanner> createState() => _CompactReferralBannerState();
}

class _CompactReferralBannerState extends State<_CompactReferralBanner> {
  bool _copied = false;

  void _copy() {
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: const Icon(Icons.person_add_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'برنامج المكافآت',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'كود: PIGEON123',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _copy,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  const SizedBox(width: 4),
                  Text(
                    _copied ? 'تم النسخ' : 'نسخ',
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
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
