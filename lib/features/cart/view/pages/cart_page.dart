import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/file_source_sheet.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/cart_item_model.dart';
import '../../viewmodel/cart_bloc.dart';
import 'order_confirmation_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          (curr.status == CartStatus.checkedOut &&
              prev.status != CartStatus.checkedOut) ||
          (curr.status == CartStatus.error &&
              prev.status == CartStatus.checkingOut),
      listener: (context, state) {
        if (state.status == CartStatus.checkedOut) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderConfirmationPage(
                order: state.lastOrder!,
                proofFile: state.checkoutProofFile,
              ),
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l.checkoutError),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isBusy =
            state.status == CartStatus.loading ||
            state.status == CartStatus.mutating ||
            state.status == CartStatus.checkingOut;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            showCartAction: false,
            titleWidget: Row(
              children: [
                Text(
                  l.cartTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
                if (state.itemsCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.itemsCount}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!state.isEmpty)
                TextButton(
                  onPressed: isBusy
                      ? null
                      : () => context.read<CartBloc>().add(const CartCleared()),
                  child: Text(
                    l.clearCartBtn,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
          body: state.status == CartStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : state.isEmpty
              ? _EmptyCart(onBrowse: () => Navigator.pop(context))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.cart!.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = state.cart!.items[index];
                          return _CartItemCard(
                            item: item,
                            isBusy: isBusy,
                            onRemove: () => context.read<CartBloc>().add(
                              CartItemRemoved(item.id),
                            ),
                            onQuantityChanged: (qty) => context
                                .read<CartBloc>()
                                .add(CartItemQuantityChanged(item.id, qty)),
                          );
                        },
                      ),
                    ),
                    _CartFooter(
                      subtotal: state.cart!.subtotal,
                      isBusy: isBusy,
                      isCheckingOut: state.status == CartStatus.checkingOut,
                      proofFile: _proofFile,
                      noteController: _noteController,
                      onPickProof: _pickProof,
                      onCheckout: () {
                        context.read<CartBloc>().add(
                          CartCheckoutRequested(
                            proofFile: _proofFile,
                            buyerNote: _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              l.emptyCartTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.emptyCartSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l.browseMarket),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart item card ───────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isBusy;
  final VoidCallback onRemove;
  final void Function(int qty) onQuantityChanged;

  const _CartItemCard({
    required this.item,
    required this.isBusy,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Title — rightmost in RTL
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Remove button — leftmost in RTL
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: isBusy ? null : onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.sellerNickname,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Quantity stepper — rightmost in RTL
              _QuantityStepper(
                quantity: item.quantity,
                isBusy: isBusy,
                onChanged: onQuantityChanged,
              ),
              const Spacer(),
              // Total price — leftmost in RTL
              Text(
                '${item.total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${item.unitPrice.toStringAsFixed(2)} ر.س × ${item.quantity}',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool isBusy;
  final void Function(int) onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.isBusy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease — rightmost in RTL
          _StepButton(
            icon: Icons.remove,
            onTap: isBusy || quantity <= 1
                ? null
                : () => onChanged(quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          // Increase — leftmost in RTL
          _StepButton(
            icon: Icons.add,
            onTap: isBusy ? null : () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? AppColors.textHint : AppColors.primary,
        ),
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  final double subtotal;
  final bool isBusy;
  final bool isCheckingOut;
  final PlatformFile? proofFile;
  final TextEditingController noteController;
  final VoidCallback onPickProof;
  final VoidCallback onCheckout;

  const _CartFooter({
    required this.subtotal,
    required this.isBusy,
    required this.isCheckingOut,
    required this.proofFile,
    required this.noteController,
    required this.onPickProof,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canCheckout = proofFile != null && !isBusy;
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
          // ── Proof picker ──────────────────────────────────────────
          _ProofPickerRow(
            proofFile: proofFile,
            isBusy: isBusy,
            onPick: onPickProof,
          ),
          const SizedBox(height: 10),
          // ── Note field ────────────────────────────────────────────
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
          const SizedBox(height: 12),
          // ── Total row ─────────────────────────────────────────────
          Row(
            children: [
              // Label — rightmost in RTL
              Text(
                l.total,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              // Amount — leftmost in RTL
              Text(
                '${subtotal.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Checkout button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCheckout ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.4,
                ),
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
                      l.completeOrder,
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

class _ProofPickerRow extends StatelessWidget {
  final PlatformFile? proofFile;
  final bool isBusy;
  final VoidCallback onPick;

  const _ProofPickerRow({
    required this.proofFile,
    required this.isBusy,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: isBusy ? null : onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: proofFile != null
              ? AppColors.primaryLight
              : AppColors.pageBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: proofFile != null ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Icon — rightmost in RTL
            Icon(
              proofFile != null
                  ? Icons.check_circle_rounded
                  : Icons.attach_file_rounded,
              size: 18,
              color: proofFile != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.paymentProofSheetTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: proofFile != null
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (proofFile != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      proofFile!.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      l.proofRequiredHint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Preview thumbnail or change icon — leftmost in RTL
            if (proofFile?.path != null) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(proofFile!.path!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              Icon(Icons.add_photo_alternate_outlined,
                  size: 20, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}
