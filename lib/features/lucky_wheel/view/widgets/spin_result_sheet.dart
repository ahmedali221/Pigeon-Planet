import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../model/wheel_spin_result_model.dart';
import '../../../../l10n/app_localizations.dart';

class SpinResultSheet extends StatelessWidget {
  final WheelSpinResultModel result;

  const SpinResultSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isLuckyNext = result.prizeType == 'lucky_next';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Prize icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: result.prizeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: result.prizeColor.withValues(alpha: 0.4),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Text(
                  result.prizeEmoji,
                  style: const TextStyle(fontSize: 46),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              isLuckyNext ? AppLocalizations.of(context).jrbHzkMraAkhra : AppLocalizations.of(context).thanyna,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Prize name
            Text(
              result.prizeLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: result.prizeColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              result.prizeDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLuckyNext ? AppColors.textSecondary : result.prizeColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLuckyNext ? AppLocalizations.of(context).upcoming2 : AppLocalizations.of(context).rayaAstlmJayztk,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
