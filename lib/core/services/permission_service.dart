import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Requests photo/gallery access. Returns true if granted or limited.
  /// permission_handler 11.x maps Permission.photos to READ_MEDIA_IMAGES on
  /// Android 13+ (API 33+) and READ_EXTERNAL_STORAGE on older versions.
  static Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  /// Requests all permissions the app needs upfront so the user approves
  /// them on first launch rather than being prompted mid-task.
  static Future<void> requestStartupPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();
  }
}
