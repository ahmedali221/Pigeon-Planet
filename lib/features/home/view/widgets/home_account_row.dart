import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class HomeAccountRow extends StatelessWidget {
  final bool isServiceProvider;
  /// True while [AuthBloc] is switching profile (blocks duplicate requests).
  final bool isProfileSwitching;
  final String? balanceText;
  final ValueChanged<bool> onToggle;

  const HomeAccountRow({
    super.key,
    required this.isServiceProvider,
    this.isProfileSwitching = false,
    this.balanceText,
    required this.onToggle,
  });

  void _onTap(bool wantSeller) {
    if (isProfileSwitching) return;
    onToggle(wantSeller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Row(
        children: [
          // buyer mode button
          GestureDetector(
            onTap: () => _onTap(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: !isServiceProvider ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'مشترى',
                style: TextStyle(
                  color: !isServiceProvider ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // provider mode button
          GestureDetector(
            onTap: () => _onTap(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isServiceProvider ? AppColors.purple : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'مقدم خدمة',
                style: TextStyle(
                  color: isServiceProvider ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          // swap icon
          if (isProfileSwitching)
            SizedBox(
              width: 22,
              height: 22,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded,
                  color: AppColors.textSecondary, size: 22),
              onPressed: () => _onTap(!isServiceProvider),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 6),

          // balance chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              balanceText ?? 'ج.م 4',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // points bolt
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 20),
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '40',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
