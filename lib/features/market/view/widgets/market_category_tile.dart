import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../model/category_model.dart';

import '../../../../l10n/app_localizations.dart';

class MarketCategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  MarketCategoryTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: Offset(0, 2),
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
                child: Text(category.emoji, style: TextStyle(fontSize: 26)),
              ),
            ),

            SizedBox(width: 14),

            // name + count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).browseProducts,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            Spacer(),

            // arrow — end (left in RTL)
            Icon(Icons.forward, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
