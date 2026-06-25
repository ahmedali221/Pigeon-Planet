import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/ppw_app_bar.dart';
import '../../../../../core/di/injection.dart';
import '../../model/pedigree_document_model.dart';
import '../../viewmodel/pedigrees_bloc.dart';
import '../../viewmodel/pedigrees_event.dart';
import '../../viewmodel/pedigrees_state.dart';
import 'pedigree_detail_page.dart';

import '../../../../l10n/app_localizations.dart';
class PedigreesPage extends StatelessWidget {
  // Pre-fill birdId when opened from a bird detail page.
  final int? initialBirdId;

  PedigreesPage({super.key, this.initialBirdId});

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

  _PedigreesView({this.initialBirdId});

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
          appBar: PPWAppBar(
            title: AppLocalizations.of(context).shhadatAlnsb,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isUploading ? null : () => _pickAndUpload(context),
            backgroundColor: AppColors.purple,
            foregroundColor: Colors.white,
            icon: isUploading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(Icons.upload_file_rounded),
            label: Text(isUploading ? AppLocalizations.of(context).jaryAlrfa : AppLocalizations.of(context).rfaShhada),
          ),
          body: _Body(state: state),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final PedigreesState state;
  _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == PedigreesStatus.loading && state.documents.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.status == PedigreesStatus.error &&
        state.documents.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              SizedBox(height: 12),
              Text(
                state.errorMessage ?? AppLocalizations.of(context).errorOccurred,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (state.documents.isEmpty) {
      return _EmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: state.documents.length,
      separatorBuilder: (_, _) => SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _DocumentTile(document: state.documents[i]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
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
              child: Icon(Icons.description_outlined,
                  color: AppColors.purple, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              'لا توجد شهادات نسب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
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
  _DocumentTile({required this.document});

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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description_rounded,
                  color: AppColors.purple, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'شهادة نسب #${document.id}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  _StatusBadge(status: document.status),
                  if (document.created != null) ...[
                    SizedBox(height: 4),
                    Text(
                      _formatDate(document.created!),
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_rounded,
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
  _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'reviewed' => (AppLocalizations.of(context).tmtAlmrajaa2, AppColors.success),
      'processed' => (AppLocalizations.of(context).tmtAlmaalja2, AppColors.blue),
      'failed' => (AppLocalizations.of(context).fshlMrajaaYdwya, AppColors.orange),
      _ => (AppLocalizations.of(context).mrfwa2, AppColors.textSecondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
