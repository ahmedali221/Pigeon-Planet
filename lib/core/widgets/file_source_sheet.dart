import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_colors.dart';

class FileSourceSheet {
  static Future<PlatformFile?> show(
    BuildContext context, {
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
  }) {
    return showModalBottomSheet<PlatformFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _FileSourceSheetContent(allowedExtensions: allowedExtensions),
    );
  }
}

class _FileSourceSheetContent extends StatefulWidget {
  final List<String> allowedExtensions;

  const _FileSourceSheetContent({required this.allowedExtensions});

  @override
  State<_FileSourceSheetContent> createState() =>
      _FileSourceSheetContentState();
}

class _FileSourceSheetContentState extends State<_FileSourceSheetContent> {
  final _picker = ImagePicker();

  Future<void> _browseFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      withData: false,
      withReadStream: false,
    );
    if (!mounted) return;
    Navigator.pop(context, result?.files.first);
  }

  Future<void> _fromGallery() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null || !mounted) return;
    final size = await File(xfile.path).length();
    if (!mounted) return;
    Navigator.pop(
      context,
      PlatformFile(name: xfile.name, path: xfile.path, size: size),
    );
  }

  Future<void> _fromCamera() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile == null || !mounted) return;
    final size = await File(xfile.path).length();
    if (!mounted) return;
    Navigator.pop(
      context,
      PlatformFile(name: xfile.name, path: xfile.path, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.pickSourceTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _SourceTile(
            icon: Icons.folder_open_rounded,
            label: l.browseFiles,
            onTap: _browseFiles,
          ),
          const Divider(height: 1, indent: 56),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: l.selectFromGallery,
            onTap: _fromGallery,
          ),
          const Divider(height: 1, indent: 56),
          _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: l.takePhoto,
            onTap: _fromCamera,
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
