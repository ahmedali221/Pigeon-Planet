import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ppw_app_bar.dart';
import '../../../../core/services/permission_service.dart';

import '../../viewmodel/pigeon_id_bloc.dart';
import '../widgets/pigeon_id_shared_widgets.dart';
import 'zajel_scanner_page.dart';

import '../../../../l10n/app_localizations.dart';
class PigeonIdPhotosPage extends StatelessWidget {
  PigeonIdPhotosPage({super.key});

  Future<void> _pickPhoto(BuildContext context) async {
    final granted = await PermissionService.requestGalleryPermission();
    if (!granted) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null && context.mounted) {
      context.read<PigeonIdBloc>().add(PigeonIdPhotoAdded(picked.path));
    }
  }

  Future<void> _takePhoto(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (picked != null && context.mounted) {
      context.read<PigeonIdBloc>().add(PigeonIdPhotoAdded(picked.path));
    }
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              title: Text(AppLocalizations.of(context).capturePhoto),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text(AppLocalizations.of(context).chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(context);
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _next(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PigeonIdBloc>(),
          child: ZajelScannerPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PigeonIdBloc, PigeonIdState>(
      builder: (context, state) {
        final photos = state.photoPaths;
        final remaining = (4 - photos.length).clamp(0, 4);

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: const PPWAppBar(
            title: 'صور الحمامة',
          ),
          body: Column(
            children: [
              PigeonStepHeader(
                  current: 2, total: 4, label: AppLocalizations.of(context).addPhotos),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info banner ──────────────────────────────────
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'يجب إضافة ٤ صور على الأقل (حد أقصى ٨ صور)\nمن زوايا مختلفة: جانبي، أمامي، من فوق، الحلقة',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ── Counter ──────────────────────────────────────
                      Row(
                        children: [
                          Text(
                            '${photos.length} / ٨ صور',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Spacer(),
                          if (remaining > 0)
                            Text(
                              'متبقي $remaining صور إلزامية',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.error),
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.success, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'اكتمل الحد الأدنى',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(height: 14),

                      // ── Photo grid ───────────────────────────────────
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: (photos.length < 8)
                            ? photos.length + 1
                            : 8,
                        itemBuilder: (context, index) {
                          if (index < photos.length) {
                            return _PhotoSlot(
                              path: photos[index],
                              isMandatory: index < 4,
                              onRemove: () => context
                                  .read<PigeonIdBloc>()
                                  .add(PigeonIdPhotoRemoved(index)),
                            );
                          }
                          // add button
                          return _AddPhotoSlot(
                            isMandatory: index < 4,
                            onTap: () => _showPickerSheet(context),
                          );
                        },
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              PigeonNextButton(
                label: 'التالي — تسجيل فيديو زاجل',
                enabled: state.canProceedToVideo,
                onTap: () => _next(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String path;
  final bool isMandatory;
  final VoidCallback onRemove;

  _PhotoSlot(
      {required this.path,
      required this.isMandatory,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: path.startsWith('http')
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        if (isMandatory)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(AppLocalizations.of(context).requiredField,
                  style: TextStyle(color: Colors.white, fontSize: 9)),
            ),
          ),
        Positioned(
          top: 4,
          left: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoSlot extends StatelessWidget {
  final bool isMandatory;
  final VoidCallback onTap;

  _AddPhotoSlot({required this.isMandatory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMandatory ? AppColors.primary : AppColors.border,
            style: BorderStyle.solid,
            width: isMandatory ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color:
                  isMandatory ? AppColors.primary : AppColors.textHint,
            ),
            SizedBox(height: 4),
            Text(
              isMandatory ? AppLocalizations.of(context).requiredField : 'اختياري',
              style: TextStyle(
                fontSize: 10,
                color: isMandatory
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
