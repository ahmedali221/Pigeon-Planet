import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../model/seller_product_model.dart';
import '../../viewmodel/seller_products_bloc.dart';

import '../../../../l10n/app_localizations.dart';

// ── Public color helper (used by page for section headers) ────────────────────

const Map<String, Color> kSellerCategoryColors = {
  'birds': AppColors.primaryDark,
  'supplies': AppColors.primary,
  'accessories': AppColors.purple,
  'feeds': AppColors.orange,
  'supplements': AppColors.blue,
};

Color sellerCategoryColor(String category) =>
    kSellerCategoryColors[category] ?? AppColors.primary;

// ── Private helpers ───────────────────────────────────────────────────────────

const _statusColors = {
  'available': AppColors.success,
  'inactive': AppColors.textHint,
  'sold': AppColors.orange,
};

Color _statusColor(String status) => _statusColors[status] ?? AppColors.textHint;

// ── List card (horizontal layout) ─────────────────────────────────────────────

class SellerProductCard extends StatelessWidget {
  final SellerProductModel product;
  final VoidCallback onEdit;
  final VoidCallback? onTransfer;

  const SellerProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = sellerCategoryColor(product.category);
    final stColor = _statusColor(product.status);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catColor.withValues(alpha: 0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: thumbnail + badges + title + actions ─────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: product.thumbnailUrl != null
                        ? Image.network(
                            product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _Placeholder(
                                category: product.category, catColor: catColor),
                          )
                        : _Placeholder(
                            category: product.category, catColor: catColor),
                  ),
                ),
                SizedBox(width: 10),
                _Badge(label: product.categoryDisplayName, color: catColor),
                SizedBox(width: 8),
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
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                ),
                if (product.category == 'birds') ...[
                  SizedBox(width: 2),
                  IconButton(
                    onPressed: onTransfer,
                    tooltip: 'نقل الملكية',
                    icon: Icon(Icons.swap_horiz_rounded,
                        color: AppColors.orange, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
                SizedBox(width: 4),
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

          // ── Bottom row: price + stock + status ────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.attach_money_rounded,
                  label: AppLocalizations.of(context).jM4(product.price),
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: AppLocalizations.of(context).qtaa(product.count),
                  color: AppColors.textSecondary,
                ),
                Spacer(),
                if (product.isMarketListed) _MarketListedDot(),
                SizedBox(width: 8),
                _Badge(
                    label: product.statusDisplayName, color: stColor, small: true),
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
            id: product.id, category: product.category));
      }
    });
  }
}

// ── Grid card (image-dominant, used in grid view & horizontal sections) ────────

class SellerProductGridCard extends StatelessWidget {
  final SellerProductModel product;
  final VoidCallback onEdit;
  final VoidCallback? onTransfer;

  const SellerProductGridCard({
    super.key,
    required this.product,
    required this.onEdit,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = sellerCategoryColor(product.category);
    final stColor = _statusColor(product.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catColor.withValues(alpha: 0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Product image ─────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: product.thumbnailUrl != null
                  ? Image.network(
                      product.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) =>
                          _Placeholder(category: product.category, catColor: catColor),
                    )
                  : _Placeholder(category: product.category, catColor: catColor),
            ),
          ),

          // ── Info ──────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category + status badges
                  Row(
                    children: [
                      Flexible(
                        child: _Badge(
                          label: product.categoryDisplayName,
                          color: catColor,
                          small: true,
                        ),
                      ),
                      Spacer(),
                      _Badge(
                        label: product.statusDisplayName,
                        color: stColor,
                        small: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // title
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  // price
                  Text(
                    AppLocalizations.of(context).jM4(product.price),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Spacer(),
                  Divider(height: 1),
                  SizedBox(height: 4),
                  // actions
                  Row(
                    children: [
                      if (product.isMarketListed) _MarketListedDot(),
                      Spacer(),
                      _GridIcon(
                        icon: Icons.edit_outlined,
                        color: AppColors.primary,
                        onTap: onEdit,
                      ),
                      if (product.category == 'birds') ...[
                        SizedBox(width: 6),
                        _GridIcon(
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.orange,
                          onTap: onTransfer ?? () {},
                        ),
                      ],
                      SizedBox(width: 6),
                      _GridIcon(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        onTap: () => _confirmDelete(context),
                      ),
                    ],
                  ),
                ],
              ),
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
            id: product.id, category: product.category));
      }
    });
  }
}

// ── Shared private helpers ────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String category;
  final Color catColor;

  const _Placeholder({required this.category, required this.catColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: catColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          category == 'birds'
              ? Icons.flutter_dash_rounded
              : Icons.storefront_outlined,
          color: catColor,
          size: 32,
        ),
      ),
    );
  }
}

class _GridIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridIcon(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _Badge({required this.label, required this.color, this.small = false});

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

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _MarketListedDot extends StatelessWidget {
  const _MarketListedDot();

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
        Text('معروض',
            style: TextStyle(fontSize: 11, color: AppColors.success)),
      ],
    );
  }
}
