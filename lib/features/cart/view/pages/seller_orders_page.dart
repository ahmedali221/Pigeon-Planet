import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../model/order_item_model.dart';
import '../../viewmodel/cart_bloc.dart';
import 'order_detail_page.dart';

class SellerOrdersPage extends StatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  State<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends State<SellerOrdersPage> {
  String? _selectedStatus;

  static const _filters = [
    null,
    'pending_seller',
    'awaiting_payment_review',
    'approved',
    'rejected',
    'completed',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const SellerOrderItemsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: l.customerOrders,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<CartBloc>()
                .add(const SellerOrderItemsLoadRequested()),
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listenWhen: (p, c) =>
            p.itemActionError != c.itemActionError &&
            c.itemActionError != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.itemActionError!),
              backgroundColor: AppColors.error,
            ),
          );
        },
        buildWhen: (p, c) =>
            p.sellerOrderItems != c.sellerOrderItems ||
            p.sellerItemsLoading != c.sellerItemsLoading ||
            p.sellerItemsLoadingMore != c.sellerItemsLoadingMore ||
            p.sellerItemsHasMore != c.sellerItemsHasMore ||
            p.itemActioning != c.itemActioning ||
            p.orderError != c.orderError,
        builder: (context, state) {
          if (state.sellerItemsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.orderError != null && state.sellerOrderItems.isEmpty) {
            return _ErrorView(
              message: state.orderError!,
              onRetry: () => context
                  .read<CartBloc>()
                  .add(const SellerOrderItemsLoadRequested()),
            );
          }

          final filtered = _selectedStatus == null
              ? state.sellerOrderItems
              : state.sellerOrderItems
                  .where((i) => i.status == _selectedStatus)
                  .toList();

          return Column(
            children: [
              _FilterChips(
                filters: _filters,
                selected: _selectedStatus,
                onSelected: (s) => setState(() => _selectedStatus = s),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyView()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length +
                            (state.sellerItemsHasMore && _selectedStatus == null
                                ? 1
                                : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (i == filtered.length) {
                            return _LoadMoreButton(
                              loading: state.sellerItemsLoadingMore,
                              onPressed: () => context
                                  .read<CartBloc>()
                                  .add(const SellerOrderItemsLoadMoreRequested()),
                            );
                          }
                          return _SellerOrderItemCard(
                            item: filtered[i],
                            actioning: state.itemActioning,
                            onTap: filtered[i].orderId == null
                                ? null
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<CartBloc>(),
                                          child: OrderDetailPage(
                                              orderId: filtered[i].orderId!),
                                        ),
                                      ),
                                    ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String?> filters;
  final String? selected;
  final void Function(String?) onSelected;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  String _label(BuildContext context, String? status) {
    if (status == null) return AppLocalizations.of(context).all;
    switch (status) {
      case 'pending_seller':
        return AppLocalizations.of(context).statusPending;
      case 'awaiting_payment_review':
        return AppLocalizations.of(context).paymentUnderReview;
      case 'approved':
        return AppLocalizations.of(context).statusApproved;
      case 'rejected':
        return AppLocalizations.of(context).statusCancelled;
      case 'completed':
        return AppLocalizations.of(context).statusCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: filters.map((f) {
          final isSelected = f == selected;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  _label(context, f),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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

class _SellerOrderItemCard extends StatelessWidget {
  final OrderItemModel item;
  final bool actioning;
  final VoidCallback? onTap;

  const _SellerOrderItemCard({
    required this.item,
    required this.actioning,
    this.onTap,
  });

  bool get _isPending => item.status == 'pending_seller';
  bool get _isAwaitingPayment => item.status == 'awaiting_payment_review';

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'awaiting_payment_review':
        return AppColors.blue;
      case 'rejected':
        return AppColors.error;
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
    final color = _statusColor(item.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPending ? AppColors.orange : AppColors.border,
        ),
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
                      fontWeight: FontWeight.bold,
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
            l.orderItemSummary(item.id, item.quantity),
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            l.orderTotalSar(item.total.toStringAsFixed(2)),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          if (_isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: actioning
                        ? null
                        : () => context
                            .read<CartBloc>()
                            .add(OrderItemRejectRequested(item.id)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: actioning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : Text(l.reject),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: actioning
                        ? null
                        : () => context
                            .read<CartBloc>()
                            .add(OrderItemApproveRequested(item.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: actioning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l.accept),
                  ),
                ),
              ],
            ),
          ] else if (_isAwaitingPayment) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: actioning
                        ? null
                        : () => context.read<CartBloc>().add(
                              SellerRejectPaymentForItemRequested(item.id),
                            ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: actioning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : Text(l.reject),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: actioning
                        ? null
                        : () => context.read<CartBloc>().add(
                              SellerApprovePaymentForItemRequested(item.id),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: actioning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l.approvePaymentBtn),
                  ),
                ),
              ],
            ),
          ],
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
          Text(l.noOrdersCurrently,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
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
