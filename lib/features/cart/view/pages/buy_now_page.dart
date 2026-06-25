import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../market/model/product_model.dart';
import '../../viewmodel/cart_bloc.dart';
import 'order_confirmation_page.dart';

class BuyNowPage extends StatefulWidget {
  final ProductModel product;
  final int quantity;

  const BuyNowPage({super.key, required this.product, required this.quantity});

  @override
  State<BuyNowPage> createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  // true while we're waiting for CartItemAdded to land before checkout
  bool _addingToCart = false;

  void _onPlaceOrder() {
    setState(() => _addingToCart = true);
    context.read<CartBloc>().add(
          CartItemAdded(int.parse(widget.product.id), widget.quantity),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) {
        // item added successfully → proceed to checkout
        if (_addingToCart &&
            curr.status == CartStatus.loaded &&
            prev.status == CartStatus.mutating) {
          return true;
        }
        // checkout completed
        if (curr.status == CartStatus.checkedOut &&
            prev.status == CartStatus.checkingOut) {
          return true;
        }
        // error during add-to-cart or checkout
        if (curr.status == CartStatus.error &&
            (prev.status == CartStatus.mutating ||
                prev.status == CartStatus.checkingOut)) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (_addingToCart && state.status == CartStatus.loaded) {
          setState(() => _addingToCart = false);
          context.read<CartBloc>().add(const CartCheckoutRequested());
          return;
        }
        if (state.status == CartStatus.checkedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationPage(
                order: state.lastOrder!,
              ),
            ),
            (route) => route.isFirst,
          );
          return;
        }
        if (state.status == CartStatus.error) {
          setState(() => _addingToCart = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    AppLocalizations.of(context).errorOccurred,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        buildWhen: (prev, curr) => prev.status != curr.status,
        builder: (context, state) {
          final isBusy = _addingToCart ||
              state.status == CartStatus.mutating ||
              state.status == CartStatus.checkingOut;
          final total = widget.product.price * widget.quantity;
          final l = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: PPWAppBar(title: l.orderConfirmationTitle),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductSummaryCard(
                          product: widget.product,
                          quantity: widget.quantity,
                          total: total,
                        ),
                        const SizedBox(height: 12),
                        _SellerCard(product: widget.product),
                        const SizedBox(height: 12),
                        _OrderNoteCard(l: l),
                      ],
                    ),
                  ),
                ),
                _PlaceOrderFooter(
                  total: total,
                  isCheckingOut: isBusy,
                  onPlaceOrder: isBusy ? null : _onPlaceOrder,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final double total;

  const _ProductSummaryCard({
    required this.product,
    required this.quantity,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.products,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image — rightmost in RTL
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: product.thumbnailUrl != null
                      ? Image.network(
                          product.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _ImagePlaceholder(),
                        )
                      : _ImagePlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.quantityLabel(quantity),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Price — leftmost in RTL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  Text(
                    l.quantityLabel(quantity),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                l.total,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  final ProductModel product;

  const _SellerCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final sellerName = product.displaySellerName;
    if (sellerName.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Label — rightmost in RTL
          const Icon(Icons.storefront_rounded,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).sellerName(sellerName),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderNoteCard extends StatelessWidget {
  final AppLocalizations l;

  const _OrderNoteCard({required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.awaitingSellerApproval,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceOrderFooter extends StatelessWidget {
  final double total;
  final bool isCheckingOut;
  final VoidCallback? onPlaceOrder;

  const _PlaceOrderFooter({
    required this.total,
    required this.isCheckingOut,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                l.total,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                disabledBackgroundColor:
                    AppColors.orange.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l.confirmAndCheckout,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
