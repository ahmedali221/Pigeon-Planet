import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection.dart';
import '../../model/pedigree_document_model.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';
import 'pedigree_detail_page.dart';

class PedigreesPage extends StatelessWidget {
  // Pre-fill birdId when opened from a bird detail page.
  final int? initialBirdId;

  const PedigreesPage({super.key, this.initialBirdId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PedigreesBloc>()
        ..add(PedigreesListRequested(birdId: initialBirdId)),
      child: _PedigreesView(initialBirdId: initialBirdId),
    );
  }
}

class _PedigreesView extends StatelessWidget {
  final int? initialBirdId;

  const _PedigreesView({this.initialBirdId});

  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null || !context.mounted) return;
    context.read<PedigreesBloc>().add(
          PedigreeUploadRequested(file, birdId: initialBirdId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PedigreesBloc, PedigreesState>(
      listenWhen: (prev, curr) =>
          curr.status == PedigreesStatus.loaded &&
          prev.status == PedigreesStatus.uploading &&
          curr.selectedDocument != null,
      listener: (context, state) {
        // Navigate to detail page immediately after successful upload.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<PedigreesBloc>(),
              child: PedigreeDetailPage(document: state.selectedDocument!),
            ),
          ),
        );
      },
      builder: (context, state) {
        final isUploading = state.status == PedigreesStatus.uploading;

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: const Text(
              'شهادات النسب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isUploading ? null : () => _pickAndUpload(context),
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            icon: isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upload_file_rounded),
            label: Text(isUploading ? 'جاري الرفع...' : 'رفع شهادة'),
          ),
          body: _Body(state: state),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final PedigreesState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == PedigreesStatus.loading && state.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == PedigreesStatus.error &&
        state.documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'حدث خطأ',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (state.documents.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.documents.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _DocumentTile(document: state.documents[i]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.purple, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد شهادات نسب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اضغط على زر الرفع لإضافة شهادة نسب لطائرك',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final PedigreeDocumentModel document;
  const _DocumentTile({required this.document});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<PedigreesBloc>(),
            child: PedigreeDetailPage(document: document),
          ),
        ),
      ),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.description_rounded,
                  color: AppColors.purple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شهادة نسب #${document.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: document.status),
                  if (document.created != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(document.created!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'reviewed' => ('تمت المراجعة', AppColors.success),
      'processed' => ('تمت المعالجة', AppColors.blue),
      'failed' => ('OCR فشل — مراجعة يدوية', AppColors.orange),
      _ => ('مرفوع', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
