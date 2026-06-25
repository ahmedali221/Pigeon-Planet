import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_product_model.dart';
import '../../viewmodel/seller_products_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class SellerProductCard extends StatelessWidget {
  final SellerProductModel product;
  final VoidCallback onEdit;

  SellerProductCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  static final _statusColors = {
    'available': AppColors.success,
    'inactive': AppColors.textHint,
    'sold': AppColors.orange,
  };

  static final _categoryColors = {
    'birds': AppColors.primaryDark,
    'supplies': AppColors.primary,
    'accessories': AppColors.purple,
    'feeds': AppColors.orange,
    'supplements': AppColors.blue,
  };

  Color get _statusColor =>
      _statusColors[product.status] ?? AppColors.textHint;

  Color get _categoryColor =>
      _categoryColors[product.category] ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: thumbnail + title + badges ───────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              // RTL: thumbnail rightmost, actions leftmost
              children: [
                // thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: product.thumbnailUrl != null
                        ? Image.network(
                            product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primaryLight,
                              child: Icon(Icons.storefront_outlined,
                                  color: AppColors.primary, size: 22),
                            ),
                          )
                        : Container(
                            color: product.category == 'birds'
                                ? AppColors.primaryLight
                                : AppColors.primaryLight,
                            child: Icon(
                              product.category == 'birds'
                                  ? Icons.flutter_dash_rounded
                                  : Icons.storefront_outlined,
                              color: _categoryColor,
                              size: 22,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 10),
                // category badge
                _Badge(
                  label: product.categoryDisplayName,
                  color: _categoryColor,
                ),
                SizedBox(width: 8),
                // title
                Expanded(
                  child: Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // edit icon
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                ),
                SizedBox(width: 4),
                // delete icon
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // ── Bottom row: price, count, status, listing ───────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                // price
                _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: AppLocalizations.of(context).jM4(product.price),
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                // stock
                _InfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: AppLocalizations.of(context).qtaa(product.count),
                  color: AppColors.textSecondary,
                ),
                Spacer(),
                // market listed dot
                if (product.isMarketListed)
                  _MarketListedDot(),
                SizedBox(width: 8),
                // status badge
                _Badge(
                  label: product.statusDisplayName,
                  color: _statusColor,
                  small: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final bloc = context.read<SellerProductsBloc>();
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('حذف المنتج'),
        content: Text('هل تريد حذف "${product.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(SellerProductDeleteRequested(
          id: product.id,
          category: product.category,
        ));
      }
    });
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  _Badge({required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 7 : 9,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MarketListedDot extends StatelessWidget {
  _MarketListedDot();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          'معروض',
          style: TextStyle(fontSize: 11, color: AppColors.success),
        ),
      ],
    );
  }
}
