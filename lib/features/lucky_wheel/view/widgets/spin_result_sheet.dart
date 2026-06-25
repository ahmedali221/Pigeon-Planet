import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../model/wheel_spin_result_model.dart';
import '../../../../l10n/app_localizations.dart';

class SpinResultSheet extends StatelessWidget {
  final WheelSpinResultModel result;

  /// Called after the user dismisses the sheet — the page uses this to reset
  /// hasSpun so the wheel becomes spinnable again (if attempts remain).
  final VoidCallback onCollect;

  const SpinResultSheet({
    super.key,
    required this.result,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLuckyNext = result.prizeType == 'lucky_next';
    final hasMoreAttempts = result.remainingAttempts > 0;

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
              isLuckyNext ? l.jrbHzkMraAkhra : l.thanyna,
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
            if (result.prizeDescription.isNotEmpty)
              Text(
                result.prizeDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

            // Remaining attempts hint — shown when user can spin again
            if (hasMoreAttempts) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  l.spinAttemptsRemaining(result.remainingAttempts),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Collect / confirm button — always collects and returns to wheel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onCollect();
                },
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
                  isLuckyNext ? l.upcoming2 : l.rayaAstlmJayztk,
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
