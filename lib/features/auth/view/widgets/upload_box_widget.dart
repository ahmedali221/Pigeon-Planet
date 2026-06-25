import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/file_source_sheet.dart';
import '../../../../l10n/app_localizations.dart';

class UploadBoxWidget extends StatefulWidget {
  final String label;
  final String hint;
  final void Function(String path)? onImagePicked;

  const UploadBoxWidget({
    super.key,
    required this.label,
    required this.hint,
    this.onImagePicked,
  });

  @override
  State<UploadBoxWidget> createState() => _UploadBoxWidgetState();
}

class _UploadBoxWidgetState extends State<UploadBoxWidget> {
  String? _imagePath;

  Future<void> _pick() async {
    final file = await FileSourceSheet.show(context);
    if (file?.path != null) {
      setState(() => _imagePath = file!.path);
      widget.onImagePicked?.call(file!.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pick,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_imagePath!), fit: BoxFit.cover),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: GestureDetector(
                            onTap: () => setState(() => _imagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: AppColors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_rounded,
                          size: 32, color: AppColors.textHint),
                      const SizedBox(height: 8),
                      Text(
                        widget.hint,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.uploadSizeHint,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
