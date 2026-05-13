import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/category_model.dart';

class MarketCategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const MarketCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          // RTL: first child = rightmost. Order: emoji | name+count | spacer | arrow
          children: [
            // emoji icon — start (right in RTL)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(category.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),

            const SizedBox(width: 14),

            // name + count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تصفح المنتجات',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),

            const Spacer(),

            // arrow — end (left in RTL)
            const Icon(Icons.chevron_left_rounded,
                color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
