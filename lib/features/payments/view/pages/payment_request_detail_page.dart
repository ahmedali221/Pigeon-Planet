import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../complaints/view/pages/complaint_create_page.dart';
import '../../model/payment_request_model.dart';
import '../../viewmodel/payments_bloc.dart';

class PaymentRequestDetailPage extends StatelessWidget {
  final PaymentRequestModel initialRequest;

  const PaymentRequestDetailPage({super.key, required this.initialRequest});

  @override
  Widget build(BuildContext context) {
    final isSeller = context.select<AuthBloc, bool>((b) {
      final s = b.state;
      if (s is AuthSuccess) return s.user.isSeller;
      if (s is AuthSwitchingProfile) return s.user.isSeller;
      return false;
    });

    return BlocConsumer<PaymentsBloc, PaymentsState>(
      listenWhen: (p, c) => p.isActing && !c.isActing,
      listener: (context, state) {
        if (state.actionError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionError!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت العملية بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final request =
            state.requests
                .where((r) => r.id == initialRequest.id)
                .firstOrNull ??
            initialRequest;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'طلب دفع #${request.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(request: request),
              const SizedBox(height: 14),
              _DetailsCard(request: request),
              if (request.buyerNote != null || request.sellerNote != null) ...[
                const SizedBox(height: 14),
                _NotesCard(request: request),
              ],
              if (request.isApproved || request.isRejected) ...[
                const SizedBox(height: 14),
                _ComplaintActionCard(request: request),
              ],
              const SizedBox(height: 14),
              if (isSeller && request.isPending) ...[
                _SellerActions(request: request, isActing: state.isActing),
              ] else if (!isSeller && request.canUpdate) ...[
                _BuyerNoteEditor(request: request, isActing: state.isActing),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ComplaintActionCard extends StatelessWidget {
  final PaymentRequestModel request;

  const _ComplaintActionCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الشكاوى',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComplaintCreatePage(paymentRequest: request),
                ),
              ),
              icon: const Icon(
                Icons.report_problem_outlined,
                color: AppColors.orange,
              ),
              label: const Text(
                'تقديم شكوى',
                style: TextStyle(color: AppColors.orange),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status + amount header ─────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final PaymentRequestModel request;
  const _StatusCard({required this.request});

  Color get _color => switch (request.status) {
    'pending' => AppColors.orange,
    'approved' => AppColors.success,
    'rejected' => AppColors.error,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              request.isAuction
                  ? Icons.gavel_rounded
                  : Icons.shopping_bag_outlined,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${request.amount.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              request.statusLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Request details ────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final PaymentRequestModel request;
  const _DetailsCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Row(
            icon: Icons.tag_rounded,
            label: 'رقم الطلب',
            value: '#${request.id}',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _Row(
            icon: request.isAuction
                ? Icons.gavel_rounded
                : Icons.shopping_bag_outlined,
            label: 'النوع',
            value: request.typeLabel,
          ),
          if (request.assetTitle.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.pets_rounded,
              label: 'المنتج',
              value: request.assetTitle,
            ),
          ],
          if (request.assetCategory.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.category_outlined,
              label: 'الفئة',
              value: request.categoryLabel,
            ),
          ],
          if (request.buyerProfileId != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.person_outline_rounded,
              label: 'رقم المشتري',
              value: '#${request.buyerProfileId}',
            ),
          ],
          const Divider(height: 1, indent: 16, endIndent: 16),
          if (request.auctionItemId != null) ...[
            _Row(
              icon: Icons.inventory_2_outlined,
              label: 'رقم قطعة المزاد',
              value: '#${request.auctionItemId}',
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          if (request.orderItemId != null) ...[
            _Row(
              icon: Icons.receipt_outlined,
              label: 'رقم عنصر الطلب',
              value: '#${request.orderItemId}',
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          _Row(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ الإنشاء',
            value: fmt.format(request.created),
          ),
          if (request.approvedAt != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.check_circle_outline_rounded,
              label: 'تاريخ القبول',
              value: fmt.format(request.approvedAt!),
            ),
          ],
          if (request.rejectedAt != null) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.cancel_outlined,
              label: 'تاريخ الرفض',
              value: fmt.format(request.rejectedAt!),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notes display ──────────────────────────────────────────────────────────────

class _NotesCard extends StatelessWidget {
  final PaymentRequestModel request;
  const _NotesCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الملاحظات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (request.buyerNote != null) ...[
            const SizedBox(height: 10),
            _NoteChip(label: 'ملاحظة المشتري', text: request.buyerNote!),
          ],
          if (request.sellerNote != null) ...[
            const SizedBox(height: 10),
            _NoteChip(
              label: 'ملاحظة البائع',
              text: request.sellerNote!,
              isRed: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteChip extends StatelessWidget {
  final String label;
  final String text;
  final bool isRed;

  const _NoteChip({
    required this.label,
    required this.text,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.error : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Seller: approve / reject ───────────────────────────────────────────────────

class _SellerActions extends StatefulWidget {
  final PaymentRequestModel request;
  final bool isActing;

  const _SellerActions({required this.request, required this.isActing});

  @override
  State<_SellerActions> createState() => _SellerActionsState();
}

class _SellerActionsState extends State<_SellerActions> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _reject(BuildContext context) {
    context.read<PaymentsBloc>().add(
      PaymentRejectRequested(
        widget.request.id,
        sellerNote: _noteCtrl.text.trim().isEmpty
            ? null
            : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراء البائع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'ملاحظة الرفض (اختياري)',
              hintText: 'سبب الرفض إن وجد…',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.pageBackground,
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          if (widget.isActing)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'رفض',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<PaymentsBloc>().add(
                      PaymentApproveRequested(widget.request.id),
                    ),
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    label: const Text(
                      'قبول',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Buyer: update note ─────────────────────────────────────────────────────────

class _BuyerNoteEditor extends StatefulWidget {
  final PaymentRequestModel request;
  final bool isActing;

  const _BuyerNoteEditor({required this.request, required this.isActing});

  @override
  State<_BuyerNoteEditor> createState() => _BuyerNoteEditorState();
}

class _BuyerNoteEditorState extends State<_BuyerNoteEditor> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.request.buyerNote ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحديث ملاحظتك',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'ملاحظتك للبائع',
              hintText: 'أضف أي تعليق أو توضيح…',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.pageBackground,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          if (widget.isActing)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ctrl.text.trim().isEmpty
                    ? null
                    : () => context.read<PaymentsBloc>().add(
                        PaymentBuyerNoteUpdateRequested(
                          widget.request.id,
                          _ctrl.text.trim(),
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text('حفظ الملاحظة'),
              ),
            ),
        ],
      ),
    );
  }
}
