import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/order_model.dart';
import '../../viewmodel/cart_bloc.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const OrdersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final statusOptions = [
      (label: l.all, value: null),
      (label: l.statusPending, value: 'pending'),
      (label: l.statusProcessing, value: 'processing'),
      (label: l.statusCompleted, value: 'completed'),
      (label: l.statusCancelled, value: 'cancelled'),
      (label: l.statusPartialRejected, value: 'partial_rejected'),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: l.myOrders,
      ),
      body: Column(
        children: [
          _StatusFilter(
            selected: _selectedStatus,
            options: statusOptions,
            onSelected: (v) {
              setState(() => _selectedStatus = v);
              context.read<CartBloc>().add(OrdersLoadRequested(status: v));
            },
          ),
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              buildWhen: (p, c) =>
                  p.orders != c.orders ||
                  p.ordersLoading != c.ordersLoading ||
                  p.ordersLoadingMore != c.ordersLoadingMore ||
                  p.ordersHasMore != c.ordersHasMore ||
                  p.orderError != c.orderError,
              builder: (context, state) {
                if (state.ordersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.orderError != null) {
                  return _ErrorView(
                    message: state.orderError!,
                    onRetry: () => context.read<CartBloc>().add(
                          OrdersLoadRequested(status: _selectedStatus),
                        ),
                  );
                }
                if (state.orders.isEmpty) {
                  return const _EmptyView();
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.orders.length + (state.ordersHasMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    if (i == state.orders.length) {
                      return _LoadMoreButton(
                        loading: state.ordersLoadingMore,
                        onPressed: () => context.read<CartBloc>().add(
                              OrdersLoadMoreRequested(status: _selectedStatus),
                            ),
                      );
                    }
                    return _OrderCard(order: state.orders[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _LoadMoreButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(l.loadMore),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final String? selected;
  final List<({String label, String? value})> options;
  final void Function(String?) onSelected;

  const _StatusFilter({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = options[i];
          final active = opt.value == selected;
          return Center(
            child: ChoiceChip(
              label: Text(opt.label),
              selected: active,
              onSelected: (_) => onSelected(opt.value),
              selectedColor: AppColors.primaryLight,
              labelStyle: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: active ? AppColors.primary : AppColors.border,
              ),
              backgroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<CartBloc>(),
            child: OrderDetailPage(orderId: order.id),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.orderNumber(order.id),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.orderSummary(order.displayItemCount, order.totalPrice.toStringAsFixed(2)),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (order.created != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${order.created!.year}-${order.created!.month.toString().padLeft(2, '0')}-${order.created!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                order.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(order.status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(l.noOrdersYet,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: Text(l.retry)),
        ],
      ),
    );
  }
}
