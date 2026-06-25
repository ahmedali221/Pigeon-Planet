import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../model/order_item_model.dart';
import '../../model/order_model.dart';

class OrderConfirmationPage extends StatelessWidget {
  final OrderModel order;
  final PlatformFile? proofFile;
  const OrderConfirmationPage({super.key, required this.order, this.proofFile});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PPWAppBar(
        title: l.orderConfirmationTitle,
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Success banner ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    l.orderSentSuccess,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.awaitingSellerApproval,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Proof file banner ───────────────────────────────────
            if (proofFile != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).proofAttached,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            proofFile!.name,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ── Order summary ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l.orderNumber(order.id),
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '#${order.id}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l.statusLabel,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.orangeLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.statusLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Text(
                        l.total,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '${order.totalPrice.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Order items ─────────────────────────────────────────
            Text(
              l.products,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => _OrderItemRow(item: item)),

            const SizedBox(height: 32),

            // ── Back to home ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Pop back to home (cart page + confirmation = 2 pages)
                  int count = 0;
                  Navigator.popUntil(context, (_) => ++count > 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l.backToHome,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemModel item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item info — rightmost in RTL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.sellerNickname,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                _StatusChip(status: item.status, label: item.statusLabel),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price — leftmost in RTL
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.hasDiscount)
                Text(
                  '${item.grossTotal.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      decoration: TextDecoration.lineThrough),
                ),
              Text(
                '${item.total.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                l.quantityLabel(item.quantity),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final String label;
  const _StatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    switch (status) {
      case 'approved':
        bg = AppColors.primaryLight;
        fg = AppColors.success;
        break;
      case 'rejected':
        bg = AppColors.redLight;
        fg = AppColors.red;
        break;
      default:
        bg = AppColors.orangeLight;
        fg = AppColors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style:
              TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
