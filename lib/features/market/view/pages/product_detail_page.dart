import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../cart/view/pages/buy_now_page.dart';
import '../../../cart/view/pages/cart_page.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../../ratings/view/widgets/ratings_section.dart';
import '../../model/product_model.dart';
import '../../viewmodel/market_bloc.dart';

import '../../../../l10n/app_localizations.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          final product = state.selectedProduct;
          if (product == null) return SizedBox.shrink();
          final authState = context.read<AuthBloc>().state;
          final canRate =
              authState is AuthSuccess && authState.user.isCustomer;
          final assetId = int.tryParse(product.id);

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: PPWAppBar(
              title: product.name,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Image ─────────────────────────────────────────────────
                  _ProductImage(product: product),
                  SizedBox(height: 12),

                  // ── Name + rating ──────────────────────────────────────────
                  _ProductHeader(product: product),
                  SizedBox(height: 12),

                  // ── Description ────────────────────────────────────────────
                  _ProductDescription(product: product),
                  SizedBox(height: 12),

                  // ── Seller ─────────────────────────────────────────────────
                  if (product.displaySellerName.isNotEmpty)
                    _SellerSection(product: product),
                  if (product.displaySellerName.isNotEmpty)
                    SizedBox(height: 12),

                  if (assetId != null) ...[
                    _ProductRatingsSection(
                      assetId: assetId,
                      canRate: canRate,
                    ),
                    SizedBox(height: 12),
                  ],

                  // ── Benefits ───────────────────────────────────────────────
                  if (product.benefits.isNotEmpty)
                    _ProductBenefits(benefits: product.benefits),
                  SizedBox(height: 12),

                  SizedBox(height: 12),

                  // ── Quantity ───────────────────────────────────────────────
                  _QuantityRow(
                    quantity: state.quantity,
                    total: state.currentPrice,
                  ),
                  SizedBox(height: 20),

                  // ── Action buttons ─────────────────────────────────────────
                  _ActionButtons(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
    );
  }
}

// ── Image ─────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final ProductModel product;
  _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).width * 0.65,
          width: double.infinity,
          child: product.thumbnailUrl != null
              ? Image.network(
                  product.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _ProductImagePlaceholder(),
                )
              : _ProductImagePlaceholder(),
        ),
        // favorite
        Positioned(
          top: 12,
          left: 12,
          child: BlocBuilder<MarketBloc, MarketState>(
            buildWhen: (p, c) =>
                p.selectedProduct?.isFavorite != c.selectedProduct?.isFavorite,
            builder: (context, state) => GestureDetector(
              onTap: () => context.read<MarketBloc>().add(
                MarketFavoriteToggled(product.id),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  (state.selectedProduct?.isFavorite ?? false)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: (state.selectedProduct?.isFavorite ?? false)
                      ? AppColors.red
                      : AppColors.textHint,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        // share
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      color: AppColors.primaryLight,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
        size: 60,
      ),
    );
  }
}

// ── Name + rating ─────────────────────────────────────────────────────────────
class _ProductHeader extends StatelessWidget {
  final ProductModel product;
  _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 4),
              Text(
                product.rating.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).reviewsCount(
                  product.reviewCount,
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (product.displaySellerName.isNotEmpty) ...[
                SizedBox(width: 12),
                Text('·',
                    style: TextStyle(color: AppColors.textHint)),
                SizedBox(width: 12),
                Icon(Icons.storefront_rounded,
                    size: 14, color: AppColors.textHint),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    product.displaySellerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Description ───────────────────────────────────────────────────────────────
class _ProductDescription extends StatelessWidget {
  final ProductModel product;
  _ProductDescription({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            product.description,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seller ────────────────────────────────────────────────────────────────────
class _SellerSection extends StatelessWidget {
  final ProductModel product;
  _SellerSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).sellerLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  product.displaySellerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Benefits ──────────────────────────────────────────────────────────────────
class _ProductRatingsSection extends StatelessWidget {
  final int assetId;
  final bool canRate;

  _ProductRatingsSection({
    required this.assetId,
    required this.canRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: RatingsSection(
        targetType: RatingTargetType.asset,
        targetId: assetId,
        canRate: canRate,
      ),
    );
  }
}

class _ProductBenefits extends StatelessWidget {
  final List<String> benefits;
  _ProductBenefits({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).benefits,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          ...benefits.map(
            (b) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quantity ──────────────────────────────────────────────────────────────────
class _QuantityRow extends StatelessWidget {
  final int quantity;
  final double total;

  _QuantityRow({required this.quantity, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).quantity,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).total,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).priceEgpFormat(
                      total.toStringAsFixed(0),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              // stepper
              Row(
                children: [
                  _StepBtn(
                    icon: Icons.remove,
                    onTap: () => context.read<MarketBloc>().add(
                      MarketQuantityDecreased(),
                    ),
                  ),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _StepBtn(
                    icon: Icons.add,
                    onTap: () => context.read<MarketBloc>().add(
                      MarketQuantityIncreased(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────
class _ActionButtons extends StatefulWidget {
  const _ActionButtons();

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          _isAddingToCart &&
          ((curr.status == CartStatus.loaded &&
                  prev.status == CartStatus.mutating) ||
              (curr.status == CartStatus.error &&
                  prev.status == CartStatus.mutating)),
      listener: (context, state) {
        if (!_isAddingToCart) return;
        setState(() => _isAddingToCart = false);
        if (state.status == CartStatus.loaded) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CartBloc>(),
                child: const CartPage(),
              ),
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? AppLocalizations.of(context).errorOccurred,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        buildWhen: (p, c) => p.status != c.status,
        builder: (context, cartState) {
          final isBusy =
              _isAddingToCart || cartState.status == CartStatus.mutating;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Buy Now — skips cart, goes directly to order confirmation
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final ms = context.read<MarketBloc>().state;
                        final product = ms.selectedProduct;
                        if (product == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CartBloc>(),
                              child: BuyNowPage(
                                product: product,
                                quantity: ms.quantity,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context).buyNow,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Add to Cart — adds item then navigates to CartPage
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () {
                              final ms = context.read<MarketBloc>().state;
                              final assetId =
                                  int.tryParse(ms.selectedProduct?.id ?? '');
                              if (assetId != null) {
                                setState(() => _isAddingToCart = true);
                                context.read<CartBloc>().add(
                                  CartItemAdded(assetId, ms.quantity),
                                );
                              }
                            },
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: Text(
                        AppLocalizations.of(context).addToCart,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side:
                            const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
