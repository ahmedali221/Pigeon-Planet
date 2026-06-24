import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pedigrees/view/pages/pedigrees_page.dart';

class AuctionPedigreeButton extends StatelessWidget {
  final int? birdId;
  final bool isOwner;

  const AuctionPedigreeButton({
    super.key,
    this.birdId,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _onPressed(context),
          icon: const Icon(Icons.description_rounded, size: 18),
          label: Text(
            isOwner ? l.managePedigreeCertificate : l.viewPedigreeCertificate,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _onPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PedigreesPage(initialBirdId: birdId),
      ),
    );
  }
}
