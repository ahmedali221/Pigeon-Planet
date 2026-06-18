import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../model/pedigree_document_model.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';

class PedigreeDetailPage extends StatefulWidget {
  final PedigreeDocumentModel document;

  const PedigreeDetailPage({super.key, required this.document});

  @override
  State<PedigreeDetailPage> createState() => _PedigreeDetailPageState();
}

class _PedigreeDetailPageState extends State<PedigreeDetailPage> {
  late final TextEditingController _ringCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _ringCtrl = TextEditingController(
      text: widget.document.reviewedBirdRingNumber ??
          widget.document.extractedBirdRingNumber ??
          '',
    );
    _descCtrl = TextEditingController(
      text: widget.document.reviewedDescription ??
          widget.document.extractedDescription ??
          '',
    );
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, PedigreeDocumentModel doc) {
    final ring = _ringCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (ring.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أدخل رقم الحلقة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    context.read<PedigreesBloc>().add(PedigreeReviewSubmitted(
          documentId: doc.id,
          ringNumber: ring,
          description: desc,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PedigreesBloc, PedigreesState>(
      listenWhen: (prev, curr) =>
          curr.status == PedigreesStatus.loaded &&
          prev.status == PedigreesStatus.reviewing,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت المراجعة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      builder: (context, state) {
        // Use the live document from state if available, else fall back to initial.
        final doc = (state.selectedDocument?.id == widget.document.id
                ? state.selectedDocument
                : null) ??
            widget.document;

        final isReviewing = state.status == PedigreesStatus.reviewing;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
              'شهادة نسب #${doc.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(doc: doc),
                const SizedBox(height: 16),
                if (doc.fileUrl != null) ...[
                  _FilePreviewCard(url: doc.fileUrl!),
                  const SizedBox(height: 16),
                ],
                _ExtractedFieldsCard(doc: doc),
                const SizedBox(height: 16),
                if (doc.canReview || doc.isReviewed) ...[
                  _ReviewForm(
                    ringCtrl: _ringCtrl,
                    descCtrl: _descCtrl,
                    isReviewing: isReviewing,
                    isReviewed: doc.isReviewed,
                    onSubmit: () => _submit(context, doc),
                  ),
                ],
                if (state.status == PedigreesStatus.error &&
                    state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(message: state.errorMessage!),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final PedigreeDocumentModel doc;
  const _StatusCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color, desc) = switch (doc.status) {
      'reviewed' => (
          Icons.check_circle_rounded,
          'تمت المراجعة',
          AppColors.success,
          'تم حفظ البيانات المُراجَعة بنجاح.',
        ),
      'processed' => (
          Icons.auto_awesome_rounded,
          'تمت المعالجة',
          AppColors.blue,
          'تم استخراج البيانات. راجعها أدناه.',
        ),
      'failed' => (
          Icons.warning_amber_rounded,
          'فشل التعرف التلقائي',
          AppColors.orange,
          'لم يتم التعرف تلقائياً، يمكنك المراجعة اليدوية.',
        ),
      _ => (
          Icons.upload_rounded,
          'مرفوع',
          AppColors.textSecondary,
          'جاري معالجة الملف.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── File preview ──────────────────────────────────────────────────────────────

class _FilePreviewCard extends StatelessWidget {
  final String url;
  const _FilePreviewCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: url.toLowerCase().endsWith('.pdf')
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error, size: 48),
                  SizedBox(height: 8),
                  Text('ملف PDF',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: AppColors.textHint, size: 40),
              )),
    );
  }
}

// ── Extracted fields ──────────────────────────────────────────────────────────

class _ExtractedFieldsCard extends StatelessWidget {
  final PedigreeDocumentModel doc;
  const _ExtractedFieldsCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'البيانات المستخرجة (OCR)',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _FieldRow(
            label: 'رقم الحلقة',
            value: doc.extractedBirdRingNumber,
          ),
          const Divider(height: 20),
          _FieldRow(
            label: 'الوصف',
            value: doc.extractedDescription,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String? value;
  const _FieldRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : '—',
            style: TextStyle(
              fontSize: 13,
              color: value?.isNotEmpty == true
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Review form ───────────────────────────────────────────────────────────────

class _ReviewForm extends StatelessWidget {
  final TextEditingController ringCtrl;
  final TextEditingController descCtrl;
  final bool isReviewing;
  final bool isReviewed;
  final VoidCallback onSubmit;

  const _ReviewForm({
    required this.ringCtrl,
    required this.descCtrl,
    required this.isReviewing,
    required this.isReviewed,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  color: AppColors.purple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'المراجعة اليدوية',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary),
              ),
              if (isReviewed) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ringCtrl,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              labelText: 'رقم حلقة الطائر',
              hintText: 'مثال: EG-2024-12345',
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  const Icon(Icons.tag_rounded, color: AppColors.purple),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            textAlign: TextAlign.start,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'الوصف',
              hintText: 'وصف إضافي من شهادة النسب',
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  const Icon(Icons.notes_rounded, color: AppColors.purple),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isReviewing ? null : onSubmit,
              icon: isReviewing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(isReviewing ? 'جاري الحفظ...' : 'حفظ المراجعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
