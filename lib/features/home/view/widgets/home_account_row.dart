import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
// import '../widgets/points_system_modal.dart';

class HomeAccountRow extends StatelessWidget {
  final bool isServiceProvider;
  final bool isProfileSwitching;
  final String? pointsLabel;
  final int? pointsBalance;
  final ValueChanged<bool> onToggle;

  const HomeAccountRow({
    super.key,
    required this.isServiceProvider,
    this.isProfileSwitching = false,
    this.pointsLabel,
    this.pointsBalance,
    required this.onToggle,
  });

  void _onTap(bool wantSeller) {
    if (isProfileSwitching) return;
    onToggle(wantSeller);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _onTap(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: !isServiceProvider
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.buyerMode,
                style: TextStyle(
                  color: !isServiceProvider
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _onTap(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isServiceProvider
                    ? AppColors.orange
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.sellerMode,
                style: TextStyle(
                  color: isServiceProvider
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (isProfileSwitching)
            const SizedBox(
              width: 22,
              height: 22,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => _onTap(!isServiceProvider),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          // const SizedBox(width: 8),
          // GestureDetector(
          //   onTap: () => PointsSystemModal.show(
          //     context,
          //     pointsBalance: pointsBalance ?? 0,
          //     isSeller: isServiceProvider,
          //   ),
          //   child: Stack(
          //     clipBehavior: Clip.none,
          //     children: [
          //       Container(
          //         width: 34,
          //         height: 34,
          //         decoration: const BoxDecoration(
          //           color: AppColors.primary,
          //           shape: BoxShape.circle,
          //         ),
          //         child: const Icon(
          //           Icons.bolt_rounded,
          //           color: Colors.white,
          //           size: 20,
          //         ),
          //       ),
          //       if (pointsLabel != null && pointsLabel!.isNotEmpty)
          //         Positioned(
          //           top: -4,
          //           left: -4,
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 4,
          //               vertical: 1,
          //             ),
          //             decoration: BoxDecoration(
          //               color: AppColors.orange,
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             child: Text(
          //               pointsLabel!,
          //               style: const TextStyle(
          //                 color: Colors.white,
          //                 fontSize: 9,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
