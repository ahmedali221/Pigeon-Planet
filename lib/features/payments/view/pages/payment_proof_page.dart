import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/file_source_sheet.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/model/order_item_model.dart';
import '../../viewmodel/payments_bloc.dart';

class PaymentProofPage extends StatefulWidget {
  final OrderItemModel item;

  const PaymentProofPage({super.key, required this.item});

  @override
  State<PaymentProofPage> createState() => _PaymentProofPageState();
}

class _PaymentProofPageState extends State<PaymentProofPage> {
  PlatformFile? _proofFile;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await FileSourceSheet.show(
      context,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (file != null) setState(() => _proofFile = file);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocProvider<PaymentsBloc>(
      create: (_) => sl<PaymentsBloc>(),
      child: BlocConsumer<PaymentsBloc, PaymentsState>(
        listenWhen: (prev, curr) =>
            prev.isCreating && !curr.isCreating,
        listener: (context, state) {
          if (state.createError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.paymentProofSentSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.createError ?? l.errorOccurred),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.isCreating;
          return Scaffold(
            backgroundColor: AppColors.pageBackground,
            appBar: PPWAppBar(title: l.sendPaymentRequestTitle),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ItemSummaryCard(item: widget.item),
                        const SizedBox(height: 16),
                        _ProofPickerCard(
                          proofFile: _proofFile,
                          onPick: _pickImage,
                        ),
                        const SizedBox(height: 16),
                        _NoteField(controller: _noteController),
                      ],
                    ),
                  ),
                ),
                _SubmitFooter(
                  isSubmitting: isSubmitting,
                  canSubmit: _proofFile != null && !isSubmitting,
                  onSubmit: () {
                    if (_proofFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.proofRequired),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    context.read<PaymentsBloc>().add(
                          MarketPaymentCreateRequested(
                            widget.item.id,
                            buyerNote: _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim(),
                            proofFile: _proofFile,
                          ),
                        );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemSummaryCard extends StatelessWidget {
  final OrderItemModel item;

  const _ItemSummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final thumbUrl =
        item.assetMediaUrls.isNotEmpty ? item.assetMediaUrls.first : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail — rightmost in RTL
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 60,
              height: 60,
              child: thumbUrl != null
                  ? Image.network(
                      thumbUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _ThumbPlaceholder(),
                    )
                  : _ThumbPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.sellerName(item.sellerNickname),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
}

class _ProofPickerCard extends StatelessWidget {
  final PlatformFile? proofFile;
  final VoidCallback onPick;

  const _ProofPickerCard({required this.proofFile, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.paymentProofSheetTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.paymentProofSheetSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (proofFile != null) ...[
            _ImagePreview(proofFile: proofFile!),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(
                proofFile == null ? l.attachProofBtn : l.changeProofBtn,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
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

class _ImagePreview extends StatelessWidget {
  final PlatformFile proofFile;

  const _ImagePreview({required this.proofFile});

  @override
  Widget build(BuildContext context) {
    final path = proofFile.path;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: path != null
          ? Image.file(
              File(path),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Container(
              height: 180,
              color: AppColors.primaryLight,
              child: const Center(
                child: Icon(Icons.image_outlined,
                    size: 48, color: AppColors.primary),
              ),
            ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;

  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          labelText: l.noteForBuyerLabel,
          hintText: l.noteForBuyerHint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

class _SubmitFooter extends StatelessWidget {
  final bool isSubmitting;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const _SubmitFooter({
    required this.isSubmitting,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canSubmit ? onSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor:
                AppColors.primary.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l.sendProofBtn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
