import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/file_source_sheet.dart';
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
  bool _addingToCart = false;
  PlatformFile? _proofFile;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final file = await FileSourceSheet.show(
      context,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (file != null) setState(() => _proofFile = file);
  }

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
          context.read<CartBloc>().add(CartCheckoutRequested(
                proofFile: _proofFile,
                buyerNote: _noteController.text.trim().isEmpty
                    ? null
                    : _noteController.text.trim(),
              ));
          return;
        }
        if (state.status == CartStatus.checkedOut) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationPage(
                order: state.lastOrder!,
                proofFile: state.checkoutProofFile,
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
          final canOrder = _proofFile != null && !isBusy;

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
                        _BuyNowProofSection(
                          proofFile: _proofFile,
                          noteController: _noteController,
                          isBusy: isBusy,
                          onPick: _pickProof,
                        ),
                      ],
                    ),
                  ),
                ),
                _PlaceOrderFooter(
                  total: total,
                  isCheckingOut: isBusy,
                  onPlaceOrder: canOrder ? _onPlaceOrder : null,
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

class _BuyNowProofSection extends StatelessWidget {
  final PlatformFile? proofFile;
  final TextEditingController noteController;
  final bool isBusy;
  final VoidCallback onPick;

  const _BuyNowProofSection({
    required this.proofFile,
    required this.noteController,
    required this.isBusy,
    required this.onPick,
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
            l.paymentProofSheetTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.paymentProofSheetSubtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          // Proof picker tile
          GestureDetector(
            onTap: isBusy ? null : onPick,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: proofFile != null
                    ? AppColors.primaryLight
                    : AppColors.pageBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: proofFile != null
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    proofFile != null
                        ? Icons.check_circle_rounded
                        : Icons.add_photo_alternate_outlined,
                    size: 18,
                    color: proofFile != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      proofFile != null
                          ? proofFile!.name
                          : l.proofRequiredHint,
                      style: TextStyle(
                        fontSize: 13,
                        color: proofFile != null
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (proofFile?.path != null) ...[
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(proofFile!.path!),
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Optional note
          TextField(
            controller: noteController,
            maxLines: 2,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: l.noteForBuyerHint,
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            style: const TextStyle(fontSize: 13),
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
