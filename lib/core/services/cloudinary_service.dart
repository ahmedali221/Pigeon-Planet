import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class CloudinaryService {
  static const _cloudName = 'deilfrlsh';
  static const _apiKey = '455345892847152';
  static const _apiSecret = 'H0bL742IolyiaaL1N-PJLDO2BJg';
  static const _baseFolder = 'pigeon-planet/birds';

  static String _sign(Map<String, String> params) {
    final str =
        (params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .map((e) => '${e.key}=${e.value}')
            .join('&') +
        _apiSecret;
    return sha1.convert(utf8.encode(str)).toString();
  }

  /// Folder for a bird: pigeon-planet/birds/{ringNumber}
  static String folderFor(String ringNumber) => '$_baseFolder/$ringNumber';

  /// Upload a single image file. Returns the secure_url or null on failure.
  static Future<String?> uploadImage(
      String filePath, String ringNumber) async {
    return _upload(
      filePath: filePath,
      resourceType: 'image',
      folder: folderFor(ringNumber),
    );
  }

  /// Upload a user avatar. Returns the secure_url or null on failure.
  static Future<String?> uploadAvatar(String filePath, String username) async {
    return _upload(
      filePath: filePath,
      resourceType: 'image',
      folder: 'pigeon-planet/avatars/$username',
    );
  }

  /// Upload an auction cover image. Returns the secure_url or null on failure.
  /// [identifier] is any stable-ish slug (e.g. auction title) used to group files.
  static Future<String?> uploadAuctionThumbnail(
      String filePath, String identifier) async {
    final safe = identifier.trim().isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : identifier.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return _upload(
      filePath: filePath,
      resourceType: 'image',
      folder: 'pigeon-planet/auctions/$safe',
    );
  }

  /// Upload a product asset image. Returns the secure_url or null on failure.
  static Future<String?> uploadProductImage(
      String filePath, String category, String title) async {
    final safe = title.trim().isEmpty
        ? category
        : title.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return _upload(
      filePath: filePath,
      resourceType: 'image',
      folder: 'pigeon-planet/products/$category/$safe',
    );
  }

  /// Upload a video file. Returns the secure_url or null on failure.
  static Future<String?> uploadVideo(
      String filePath, String ringNumber) async {
    return _upload(
      filePath: filePath,
      resourceType: 'video',
      folder: folderFor(ringNumber),
    );
  }

  static Future<String?> _upload({
    required String filePath,
    required String resourceType,
    required String folder,
  }) async {
    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final params = {'folder': folder, 'timestamp': timestamp};
      final signature = _sign(params);

      final dio = Dio();
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath),
          'api_key': _apiKey,
          'timestamp': timestamp,
          'folder': folder,
          'signature': signature,
        }),
      );
      return response.data['secure_url'] as String?;
    } catch (e) {
      return null;
    }
  }
}
