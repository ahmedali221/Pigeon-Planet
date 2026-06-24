import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../payments/view/pages/payments_page.dart';
import '../../model/order_item_model.dart';
import '../../model/order_model.dart';
import '../../viewmodel/cart_bloc.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(OrderDetailRequested(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, c) =>
          p.selectedOrder != c.selectedOrder ||
          p.ordersLoading != c.ordersLoading ||
          p.orderError != c.orderError,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PPWAppBar(
            title: state.selectedOrder != null
                ? l.orderNumber(state.selectedOrder!.id)
                : l.orderDetails,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    final l = AppLocalizations.of(context);
    if (state.ordersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.orderError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 8),
            Text(state.orderError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context
                  .read<CartBloc>()
                  .add(OrderDetailRequested(widget.orderId)),
              child: Text(l.retry),
            ),
          ],
        ),
      );
    }
    final order = state.selectedOrder;
    if (order == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _OrderSummaryCard(order: order),
        const SizedBox(height: 16),
        Text(
          l.products,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        ...order.items.map((item) => _OrderItemTile(item: item)),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderModel order;

  const _OrderSummaryCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'processing':
        return AppColors.blue;
      case 'partial_rejected':
        return AppColors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = _statusColor(order.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.orderNumber(order.id),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.productCount,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              Text('${order.items.length}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.total,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              Text(
                '${order.totalPrice.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemTile({required this.item});

  Color _itemStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'awaiting_payment_review':
        return AppColors.blue;
      case 'ready_handoff':
        return AppColors.primary;
      case 'completed':
        return AppColors.blue;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = _itemStatusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.sellerName(item.sellerNickname),
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.quantityLabel(item.quantity),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.hasDiscount) ...[
                    Text(
                      '${item.grossTotal.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough),
                    ),
                    Text(
                      '-${item.discountAmount.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                  Text(
                    '${item.total.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          if (item.hasCashbackEarned) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.success, size: 13),
                const SizedBox(width: 4),
                Text(
                  l.cashbackEarned(item.cashbackEarnedAmount.toStringAsFixed(2)),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
          if (item.hasCashbackRedeemed) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.blue, size: 13),
                const SizedBox(width: 4),
                Text(
                  l.cashbackRedeemed(item.cashbackRedeemedAmount.toStringAsFixed(2)),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.blue),
                ),
              ],
            ),
          ],
          if (item.status == 'approved') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PaymentsPage(pendingOrderItemId: item.id),
                  ),
                ),
                icon: const Icon(Icons.payment_rounded,
                    color: Colors.white, size: 16),
                label: Text(l.sendPaymentRequestBtn,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
