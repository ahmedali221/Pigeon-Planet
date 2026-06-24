import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class AuctionVerificationRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const AuctionVerificationRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (data['hasCertifiedPedigree'] as bool)
            AuctionVerifChip(
                label: l.verifiedPedigree, color: AppColors.primary),
          const SizedBox(width: 8),
          if (data['hasDNA'] as bool)
            AuctionVerifChip(label: l.dnaRegistered, color: AppColors.primary),
          const SizedBox(width: 8),
          if (data['hasHealthGuarantee'] as bool)
            AuctionVerifChip(
                label: l.healthGuarantee, color: AppColors.success),
        ],
      ),
    );
  }
}

class AuctionVerifChip extends StatelessWidget {
  final String label;
  final Color color;
  const AuctionVerifChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
