import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../model/pedigree_document_model.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';

import '../../../../l10n/app_localizations.dart';
class PedigreeDetailPage extends StatefulWidget {
  final PedigreeDocumentModel document;
  final bool isReadOnly;

  const PedigreeDetailPage({
    super.key,
    required this.document,
    this.isReadOnly = false,
  });

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
        SnackBar(
          content: Text(AppLocalizations.of(context).enterRingNumber),
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
          SnackBar(
            content: Text(AppLocalizations.of(context).reviewSuccess),
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
          appBar: PPWAppBar(
            title: AppLocalizations.of(context).shhadaNsb(doc.id),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(doc: doc),
                SizedBox(height: 16),
                if (doc.fileUrl != null) ...[
                  _FilePreviewCard(url: doc.fileUrl!),
                  SizedBox(height: 16),
                ],
                _ExtractedFieldsCard(doc: doc),
                SizedBox(height: 16),
                if (!widget.isReadOnly &&
                    (doc.canReview || doc.isReviewed)) ...[
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
                  SizedBox(height: 12),
                  _ErrorBanner(message: state.errorMessage!),
                ],
                SizedBox(height: 40),
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
          AppLocalizations.of(context).tmtAlmrajaa,
          AppColors.success,
          AppLocalizations.of(context).save2,
        ),
      'processed' => (
          Icons.auto_awesome_rounded,
          AppLocalizations.of(context).tmtAlmaalja,
          AppColors.blue,
          AppLocalizations.of(context).tmAstkhrajAlbyanatRajahaAdnah,
        ),
      'failed' => (
          Icons.warning_amber_rounded,
          AppLocalizations.of(context).fshlAltarfAltlqayy,
          AppColors.orange,
          AppLocalizations.of(context).lmYtmAltarfTlqayyaYmknk,
        ),
      _ => (
          Icons.upload_rounded,
          AppLocalizations.of(context).mrfwa,
          AppColors.textSecondary,
          AppLocalizations.of(context).jaryMaaljaAlmlf,
        ),
    };

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
                SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
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
              offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: url.toLowerCase().endsWith('.pdf')
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error, size: 48),
                  SizedBox(height: 8),
                  Text(AppLocalizations.of(context).pdfFile,
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'البيانات المستخرجة (OCR)',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 12),
          _FieldRow(
            label: AppLocalizations.of(context).ringNumber,
            value: doc.extractedBirdRingNumber,
          ),
          Divider(height: 20),
          _FieldRow(
            label: AppLocalizations.of(context).description,
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
            style: TextStyle(
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded,
                  color: AppColors.purple, size: 20),
              SizedBox(width: 8),
              Text(
                'المراجعة اليدوية',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary),
              ),
              if (isReviewed) ...[
                SizedBox(width: 8),
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 16),
              ],
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: ringCtrl,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).pedigreeRingLabel,
              hintText: AppLocalizations.of(context).pedigreeRingHint,
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  Icon(Icons.tag_rounded, color: AppColors.purple),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            textAlign: TextAlign.start,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
              hintText: AppLocalizations.of(context).pedigreeDescHint,
              filled: true,
              fillColor: AppColors.inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon:
                  Icon(Icons.notes_rounded, color: AppColors.purple),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isReviewing ? null : onSubmit,
              icon: isReviewing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.save_rounded, size: 18),
              label: Text(isReviewing ? AppLocalizations.of(context).save3 : AppLocalizations.of(context).save4),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
