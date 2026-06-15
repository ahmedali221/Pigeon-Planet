import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/permission_service.dart';

class AvatarPickerWidget extends StatefulWidget {
  final void Function(String? path) onChanged;
  final double size;

  const AvatarPickerWidget({
    super.key,
    required this.onChanged,
    this.size = 90,
  });

  @override
  State<AvatarPickerWidget> createState() => _AvatarPickerWidgetState();
}

class _AvatarPickerWidgetState extends State<AvatarPickerWidget> {
  String? _imagePath;
  final _picker = ImagePicker();

  Future<void> _pick() async {
    final granted = await PermissionService.requestGalleryPermission();
    if (!granted) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
      widget.onChanged(picked.path);
    }
  }

  void _remove() {
    setState(() => _imagePath = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.size / 2;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _pick,
            child: CircleAvatar(
              radius: r,
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  _imagePath != null ? FileImage(File(_imagePath!)) : null,
              child: _imagePath == null
                  ? Icon(Icons.person_rounded,
                      color: AppColors.primary, size: r * 0.9)
                  : null,
            ),
          ),
          // Camera badge
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: _imagePath != null ? _remove : _pick,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _imagePath != null ? Colors.red.shade400 : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  _imagePath != null ? Icons.close_rounded : Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
