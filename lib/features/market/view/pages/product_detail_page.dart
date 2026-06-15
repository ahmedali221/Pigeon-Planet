import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../cart/viewmodel/cart_bloc.dart';
import '../../model/product_model.dart';
import '../../viewmodel/market_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          (curr.status == CartStatus.loaded &&
              prev.status == CartStatus.mutating) ||
          (curr.status == CartStatus.error &&
              prev.status == CartStatus.mutating),
      listener: (context, state) {
        if (state.status == CartStatus.loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت الإضافة إلى السلة'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, state) {
          final product = state.selectedProduct;
          if (product == null) return const SizedBox.shrink();

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Image ─────────────────────────────────────────────────
                  _ProductImage(product: product),
                  const SizedBox(height: 12),

                  // ── Name + rating ──────────────────────────────────────────
                  _ProductHeader(product: product),
                  const SizedBox(height: 12),

                  // ── Description ────────────────────────────────────────────
                  _ProductDescription(product: product),
                  const SizedBox(height: 12),

                  // ── Benefits ───────────────────────────────────────────────
                  if (product.benefits.isNotEmpty)
                    _ProductBenefits(benefits: product.benefits),
                  const SizedBox(height: 12),

                  const SizedBox(height: 12),

                  // ── Quantity ───────────────────────────────────────────────
                  _QuantityRow(
                    quantity: state.quantity,
                    total: state.currentPrice,
                  ),
                  const SizedBox(height: 20),

                  // ── Action buttons ─────────────────────────────────────────
                  _ActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Image ─────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final ProductModel product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Image.network(
            'https://picsum.photos/seed/${product.seed}/400/300',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 260,
              color: AppColors.primaryLight,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary,
                size: 60,
              ),
            ),
          ),
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
                decoration: const BoxDecoration(
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
              child: const Icon(
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

// ── Name + rating ─────────────────────────────────────────────────────────────
class _ProductHeader extends StatelessWidget {
  final ProductModel product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                product.rating.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${product.reviewCount} تقييم)',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
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
  const _ProductDescription({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصف',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            textAlign: TextAlign.start,
            style: const TextStyle(
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

// ── Benefits ──────────────────────────────────────────────────────────────────
class _ProductBenefits extends StatelessWidget {
  final List<String> benefits;
  const _ProductBenefits({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الفوائد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: const TextStyle(
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

  const _QuantityRow({required this.quantity, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الكمية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // total
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'ج.م ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
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
                      const MarketQuantityDecreased(),
                    ),
                  ),
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _StepBtn(
                    icon: Icons.add,
                    onTap: () => context.read<MarketBloc>().add(
                      const MarketQuantityIncreased(),
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
  const _StepBtn({required this.icon, required this.onTap});

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
class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final isBusy = cartState.status == CartStatus.mutating;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Buy now — adds to cart and stays on the current page
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isBusy
                        ? null
                        : () {
                            final ms = context.read<MarketBloc>().state;
                            final id = ms.selectedProduct?.id;
                            final assetId = int.tryParse(id ?? '');
                            if (assetId != null) {
                              context.read<CartBloc>().add(
                                CartItemAdded(assetId, ms.quantity),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'اشتري الآن',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Add to cart — dispatches to CartBloc; listener shows snackbar
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () {
                            final ms = context.read<MarketBloc>().state;
                            final id = ms.selectedProduct?.id;
                            final assetId = int.tryParse(id ?? '');
                            if (assetId != null) {
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
                    label: const Text(
                      'أضف إلى السلة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
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
    );
  }
}
