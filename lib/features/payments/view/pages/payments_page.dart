import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../model/payment_request_model.dart';
import '../../viewmodel/payments_bloc.dart';
import 'payment_request_detail_page.dart';

import '../../../../l10n/app_localizations.dart';

class PaymentsPage extends StatelessWidget {
  final int? pendingAuctionItemId;
  final int? pendingOrderItemId;
  final String? pendingBuyerNote;
  final PlatformFile? pendingProofFile;

  PaymentsPage({
    super.key,
    this.pendingAuctionItemId,
    this.pendingOrderItemId,
    this.pendingBuyerNote,
    this.pendingProofFile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsBloc>(
      create: (_) {
        final bloc = sl<PaymentsBloc>();
        if (pendingAuctionItemId != null) {
          bloc.add(
            AuctionPaymentCreateRequested(
              pendingAuctionItemId!,
              buyerNote: pendingBuyerNote,
            ),
          );
        } else if (pendingOrderItemId != null) {
          bloc.add(
            MarketPaymentCreateRequested(
              pendingOrderItemId!,
              buyerNote: pendingBuyerNote,
              proofFile: pendingProofFile,
            ),
          );
        } else {
          bloc.add(PaymentsLoadRequested());
        }
        return bloc;
      },
      child: _PaymentsView(),
    );
  }
}

class _PaymentsView extends StatelessWidget {
  _PaymentsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentsBloc, PaymentsState>(
      listenWhen: (p, c) => p.isCreating && !c.isCreating,
      listener: (context, state) {
        if (state.reusedExistingRequest) return;
        if (state.createError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.createError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).paymentRequestSentSuccess,
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PPWAppBar(title: AppLocalizations.of(context).paymentRequests),
        body: BlocBuilder<PaymentsBloc, PaymentsState>(
          builder: (context, state) {
            if (state.isCreating) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).sendingPaymentRequest,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.status == PaymentsStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.status == PaymentsStatus.error) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 12),
                      Text(
                        state.errorMessage ??
                            AppLocalizations.of(context).errorOccurred,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<PaymentsBloc>().add(
                          PaymentsLoadRequested(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).noPaymentRequests,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async =>
                  context.read<PaymentsBloc>().add(PaymentsLoadRequested()),
              child: ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: state.requests.length,
                separatorBuilder: (_, _) => SizedBox(height: 10),
                itemBuilder: (context, i) => _PaymentRequestCard(
                  request: state.requests[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<PaymentsBloc>(),
                        child: PaymentRequestDetailPage(
                          initialRequest: state.requests[i],
                        ),
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

  _PaymentRequestCard({required this.request, required this.onTap});

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
        padding: EdgeInsets.all(14),
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
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).paymentRequestNum(request.id),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          request.typeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (request.assetTitle.isNotEmpty) ...[
                    SizedBox(height: 2),
                    Text(
                      request.assetTitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).jM4(request.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    fmt.format(request.created),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
