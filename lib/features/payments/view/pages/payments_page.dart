import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/payment_request_model.dart';
import '../../viewmodel/payments_bloc.dart';
import 'payment_request_detail_page.dart';

class PaymentsPage extends StatelessWidget {
  final int? pendingAuctionItemId;
  final int? pendingOrderItemId;
  final String? pendingBuyerNote;

  const PaymentsPage({
    super.key,
    this.pendingAuctionItemId,
    this.pendingOrderItemId,
    this.pendingBuyerNote,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsBloc>(
      create: (_) {
        final bloc = sl<PaymentsBloc>();
        if (pendingAuctionItemId != null) {
          bloc.add(AuctionPaymentCreateRequested(
            pendingAuctionItemId!,
            buyerNote: pendingBuyerNote,
          ));
        } else if (pendingOrderItemId != null) {
          bloc.add(MarketPaymentCreateRequested(
            pendingOrderItemId!,
            buyerNote: pendingBuyerNote,
          ));
        } else {
          bloc.add(const PaymentsLoadRequested());
        }
        return bloc;
      },
      child: const _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  const _PaymentsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentsBloc, PaymentsState>(
      listenWhen: (p, c) => p.isCreating && !c.isCreating,
      listener: (context, state) {
        if (state.createError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.createError!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم إرسال طلب الدفع بنجاح'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'طلبات الدفع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        body: BlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, state) {
            if (state.isCreating) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('جاري إرسال طلب الدفع…',
                        style:
                            TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              );
            }

            if (state.status == PaymentsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == PaymentsStatus.error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(state.errorMessage ?? 'حدث خطأ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<PaymentsBloc>()
                            .add(const PaymentsLoadRequested()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.requests.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 64, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('لا توجد طلبات دفع حتى الآن',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 15)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context
                  .read<PaymentsBloc>()
                  .add(const PaymentsLoadRequested()),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _PaymentRequestCard(
                  request: state.requests[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PaymentsBloc>(),
                        child: PaymentRequestDetailPage(
                            initialRequest: state.requests[i]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentRequestCard extends StatelessWidget {
  final PaymentRequestModel request;
  final VoidCallback onTap;

  const _PaymentRequestCard({required this.request, required this.onTap});

  Color get _statusColor => switch (request.status) {
        'pending' => AppColors.orange,
        'approved' => AppColors.success,
        'rejected' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final fmt = DateFormat('yyyy/MM/dd');

    return GestureDetector(
      onTap: onTap,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                request.isAuction
                    ? Icons.gavel_rounded
                    : Icons.shopping_bag_outlined,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'طلب #${request.id}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          request.typeLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ),
                    ],
                  ),
                  if (request.assetTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      request.assetTitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${request.amount.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(request.created),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                request.statusLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
