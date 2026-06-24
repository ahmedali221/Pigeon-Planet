import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../auth/viewmodel/auth_bloc.dart';
import '../../../complaints/view/pages/complaint_create_page.dart';
import '../../model/payment_request_model.dart';
import '../../viewmodel/payments_bloc.dart';

import '../../../../l10n/app_localizations.dart';
class PaymentRequestDetailPage extends StatelessWidget {
  final PaymentRequestModel initialRequest;

  PaymentRequestDetailPage({super.key, required this.initialRequest});

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
            SnackBar(
              content: Text(AppLocalizations.of(context).operationSuccessful),
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
          appBar: PPWAppBar(
            title: 'طلب دفع #${request.id}',
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _StatusCard(request: request),
              SizedBox(height: 14),
              _DetailsCard(request: request),
              if (request.buyerNote != null || request.sellerNote != null) ...[
                SizedBox(height: 14),
                _NotesCard(request: request),
              ],
              if (request.paymentProofUrl != null) ...[
                SizedBox(height: 14),
                _ProofCard(url: request.paymentProofUrl!),
              ],
              if (request.isApproved || request.isRejected) ...[
                SizedBox(height: 14),
                _ComplaintActionCard(request: request),
              ],
              SizedBox(height: 14),
              if (isSeller && request.isPending) ...[
                _SellerActions(request: request, isActing: state.isActing),
              ] else if (!isSeller && request.canUpdate) ...[
                _BuyerNoteEditor(request: request, isActing: state.isActing),
              ],
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ComplaintActionCard extends StatelessWidget {
  final PaymentRequestModel request;

  _ComplaintActionCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الشكاوى',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComplaintCreatePage(paymentRequest: request),
                ),
              ),
              icon: Icon(
                Icons.report_problem_outlined,
                color: AppColors.orange,
              ),
              label: Text(
                'تقديم شكوى',
                style: TextStyle(color: AppColors.orange),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.orange),
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
  _StatusCard({required this.request});

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
      padding: EdgeInsets.all(20),
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
          SizedBox(height: 12),
          Text(
            '${request.amount.toStringAsFixed(2)} ج.م',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
  _DetailsCard({required this.request});

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
          Divider(height: 1, indent: 16, endIndent: 16),
          _Row(
            icon: request.isAuction
                ? Icons.gavel_rounded
                : Icons.shopping_bag_outlined,
            label: 'النوع',
            value: request.typeLabel,
          ),
          if (request.assetTitle.isNotEmpty) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.pets_rounded,
              label: 'المنتج',
              value: request.assetTitle,
            ),
          ],
          if (request.assetCategory.isNotEmpty) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.category_outlined,
              label: 'الفئة',
              value: request.categoryLabel,
            ),
          ],
          if (request.buyerProfileId != null) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.person_outline_rounded,
              label: 'رقم المشتري',
              value: '#${request.buyerProfileId}',
            ),
          ],
          Divider(height: 1, indent: 16, endIndent: 16),
          if (request.auctionItemId != null) ...[
            _Row(
              icon: Icons.inventory_2_outlined,
              label: 'رقم قطعة المزاد',
              value: '#${request.auctionItemId}',
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
          ],
          if (request.orderItemId != null) ...[
            _Row(
              icon: Icons.receipt_outlined,
              label: 'رقم عنصر الطلب',
              value: '#${request.orderItemId}',
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
          ],
          _Row(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ الإنشاء',
            value: fmt.format(request.created),
          ),
          if (request.approvedAt != null) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
            _Row(
              icon: Icons.check_circle_outline_rounded,
              label: 'تاريخ القبول',
              value: fmt.format(request.approvedAt!),
            ),
          ],
          if (request.rejectedAt != null) ...[
            Divider(height: 1, indent: 16, endIndent: 16),
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

  _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
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
  _NotesCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الملاحظات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (request.buyerNote != null) ...[
            SizedBox(height: 10),
            _NoteChip(label: 'ملاحظة المشتري', text: request.buyerNote!),
          ],
          if (request.sellerNote != null) ...[
            SizedBox(height: 10),
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

  _NoteChip({
    required this.label,
    required this.text,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.error : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
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
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Payment proof ─────────────────────────────────────────────────────────────

class _ProofCard extends StatelessWidget {
  final String url;
  _ProofCard({required this.url});

  bool get _isImage =>
      url.toLowerCase().endsWith('.jpg') ||
      url.toLowerCase().endsWith('.jpeg') ||
      url.toLowerCase().endsWith('.png');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إثبات الدفع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          if (_isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => _ProofFallbackLink(label: 'فتح الصورة'),
              ),
            )
          else
            _ProofFallbackLink(label: url.split('/').last),
        ],
      ),
    );
  }
}

class _ProofFallbackLink extends StatelessWidget {
  final String label;
  _ProofFallbackLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Seller: approve / reject ───────────────────────────────────────────────────

class _SellerActions extends StatefulWidget {
  final PaymentRequestModel request;
  final bool isActing;

  _SellerActions({required this.request, required this.isActing});

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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراء البائع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).rejectionNoteLabel,
              hintText: AppLocalizations.of(context).rejectionNoteHint,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.pageBackground,
            ),
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 12),
          if (widget.isActing)
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                    ),
                    label: Text(
                      AppLocalizations.of(context).reject,
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<PaymentsBloc>().add(
                      PaymentApproveRequested(widget.request.id),
                    ),
                    icon: Icon(Icons.check_rounded, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context).accept,
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 14),
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

  _BuyerNoteEditor({required this.request, required this.isActing});

  @override
  State<_BuyerNoteEditor> createState() => _BuyerNoteEditorState();
}

class _BuyerNoteEditorState extends State<_BuyerNoteEditor> {
  late final TextEditingController _ctrl;
  PlatformFile? _proofFile;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _proofFile = result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحديث ملاحظتك',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).noteForBuyerLabel,
              hintText: AppLocalizations.of(context).noteForBuyerHint,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.pageBackground,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: Icon(Icons.attach_file_rounded, size: 18),
            label: Text(
              _proofFile == null ? 'إرفاق إثبات الدفع' : _proofFile!.name,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: _proofFile != null ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
          ),
          if (_proofFile != null) ...[
            SizedBox(height: 6),
            Text(
              'الملف: ${_proofFile!.name} (${(_proofFile!.size / 1024).toStringAsFixed(1)} KB)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: 12),
          if (widget.isActing)
            Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_ctrl.text.trim().isEmpty && _proofFile == null)
                    ? null
                    : () => context.read<PaymentsBloc>().add(
                        PaymentBuyerNoteUpdateRequested(
                          widget.request.id,
                          _ctrl.text.trim(),
                          proofFile: _proofFile,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(AppLocalizations.of(context).save),
              ),
            ),
        ],
      ),
    );
  }
}
