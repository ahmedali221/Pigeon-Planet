import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../model/cart_item_model.dart';
import '../../viewmodel/cart_bloc.dart';
import 'order_confirmation_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listenWhen: (prev, curr) =>
          curr.status == CartStatus.checkedOut ||
          (curr.status == CartStatus.error &&
              prev.status == CartStatus.checkingOut),
      listener: (context, state) {
        if (state.status == CartStatus.checkedOut) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderConfirmationPage(order: state.lastOrder!),
            ),
          );
        } else if (state.status == CartStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ أثناء إتمام الطلب'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state.status == CartStatus.loading ||
            state.status == CartStatus.mutating ||
            state.status == CartStatus.checkingOut;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                const Text(
                  'عربة التسوق',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                if (state.itemsCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
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
                      : () => context
                          .read<CartBloc>()
                          .add(const CartCleared()),
                  child: const Text(
                    'إفراغ',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
          body: state.status == CartStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : state.isEmpty
                  ? _EmptyCart(onBrowse: () => Navigator.pop(context))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.cart!.items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = state.cart!.items[index];
                              return _CartItemCard(
                                item: item,
                                isBusy: isBusy,
                                onRemove: () => context
                                    .read<CartBloc>()
                                    .add(CartItemRemoved(item.id)),
                                onQuantityChanged: (qty) => context
                                    .read<CartBloc>()
                                    .add(CartItemQuantityChanged(
                                        item.id, qty)),
                              );
                            },
                          ),
                        ),
                        _CartFooter(
                          subtotal: state.cart!.subtotal,
                          isBusy: isBusy,
                          isCheckingOut:
                              state.status == CartStatus.checkingOut,
                          onCheckout: () => context
                              .read<CartBloc>()
                              .add(const CartCheckoutRequested()),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'عربتك فارغة',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'تصفّح السوق وأضف منتجات إلى عربتك',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('تصفّح السوق'),
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
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
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
                fontSize: 12, color: AppColors.textSecondary),
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
            style: const TextStyle(
                fontSize: 11, color: AppColors.textHint),
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
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
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
        child: Icon(icon,
            size: 16,
            color: onTap == null ? AppColors.textHint : AppColors.primary),
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  final double subtotal;
  final bool isBusy;
  final bool isCheckingOut;
  final VoidCallback onCheckout;

  const _CartFooter({
    required this.subtotal,
    required this.isBusy,
    required this.isCheckingOut,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
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
              // Label — rightmost in RTL
              const Text(
                'الإجمالي',
                style: TextStyle(
                    fontSize: 16, color: AppColors.textSecondary),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isBusy ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      'إتمام الطلب',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
