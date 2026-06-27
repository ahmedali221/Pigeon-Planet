import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../model/product_model.dart';
import '../../viewmodel/market_bloc.dart';

import '../../../../l10n/app_localizations.dart';

class MarketProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  MarketProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final basePrice = product.price > 0
        ? product.price.toStringAsFixed(0)
        : '—';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: SizedBox(
                    height: constraints.maxWidth * 0.72,
                    width: double.infinity,
                    child: product.thumbnailUrl != null
                        ? Image.network(
                            product.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.primaryLight,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.primaryLight,
                            child: Icon(
                              Icons.storefront_outlined,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                  ),
                ),
                // best seller badge
                if (product.isBestSeller)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppLocalizations.of(context).bestSeller,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // favorite button
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => context.read<MarketBloc>().add(
                      MarketFavoriteToggled(product.id),
                    ),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.isFavorite
                            ? AppColors.red
                            : AppColors.textHint,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                product.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // rating
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  SizedBox(width: 3),
                  Text(
                    product.rating.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    '(${product.reviewCount})',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // ── Price + cart ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                // RTL: price first (rightmost), cart button last (leftmost)
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // price — start (right in RTL)
                  Text(
                    product.price > 0
                        ? AppLocalizations.of(context).priceEgpFormat(basePrice)
                        : basePrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  // cart button — end (left in RTL)
                  GestureDetector(
                    onTap: () {
                      final assetId = int.tryParse(product.id);
                      if (assetId == null) return;
                      context.read<CartBloc>().add(CartItemAdded(assetId, 1));
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
