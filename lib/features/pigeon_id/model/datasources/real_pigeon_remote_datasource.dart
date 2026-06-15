import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../pigeon_model.dart';
import 'pigeon_remote_datasource.dart';

class RealPigeonRemoteDataSource implements PigeonRemoteDataSource {
  final DioClient _dio;

  const RealPigeonRemoteDataSource(this._dio);

  // ── Cloudinary helpers ──────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _uploadImages(
      List<String> paths, String ringNumber) async {
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < paths.length; i++) {
      final url = await CloudinaryService.uploadImage(paths[i], ringNumber);
      if (url != null) {
        result.add({
          'image_url': url,
          'is_primary': i == 0,
          'order': i,
        });
      }
    }
    return result;
  }

  // ── Shared body builder ─────────────────────────────────────────────────────

  Map<String, dynamic> _body(PigeonModel pigeon) => {
        'name': pigeon.name.isNotEmpty ? pigeon.name : pigeon.ringNumber,
        'ring_number': pigeon.ringNumber,
        'title': pigeon.name.isNotEmpty ? pigeon.name : pigeon.ringNumber,
        'gender': pigeon.gender == PigeonGender.female ? 'female' : 'male',
        'colour': pigeon.breed,
        if (pigeon.hatchDate != null)
          'birthday': pigeon.hatchDate!.toIso8601String().split('T').first,
        'is_market_listed': pigeon.isMarketListed,
        'achievements': pigeon.achievements,
        'stamina_ability': pigeon.staminaAbility.apiValue,
        'price': pigeon.price.toStringAsFixed(2),
        'description': pigeon.description,
        if (pigeon.flyingSpeed != null)
          'flying_speed': pigeon.flyingSpeed!.toStringAsFixed(2),
      };

  // ── Public API ──────────────────────────────────────────────────────────────

  @override
  Future<PigeonModel> saveBird(PigeonModel pigeon) async {
    final images = await _uploadImages(pigeon.photoPaths, pigeon.ringNumber);

    String? videoUrl;
    if (pigeon.videoPath != null) {
      videoUrl = await CloudinaryService.uploadVideo(
          pigeon.videoPath!, pigeon.ringNumber);
    }

    final body = {
      ..._body(pigeon),
      'is_for_auction': false,
      'category': 'bird',
      'count': 1,
      if (images.isNotEmpty) 'images': images,
      if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
    };

    final response = await _dio.post(ApiConstants.birds, data: body);
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PigeonModel> updateBird(int id, PigeonModel pigeon) async {
    // Only re-upload images when the caller supplies local paths.
    // If photoPaths are already https:// URLs (loaded from server), skip upload.
    final localPaths =
        pigeon.photoPaths.where((p) => !p.startsWith('http')).toList();
    final newImages = localPaths.isNotEmpty
        ? await _uploadImages(localPaths, pigeon.ringNumber)
        : <Map<String, dynamic>>[];

    String? videoUrl = pigeon.videoPath;
    if (pigeon.videoPath != null && !pigeon.videoPath!.startsWith('http')) {
      videoUrl = await CloudinaryService.uploadVideo(
          pigeon.videoPath!, pigeon.ringNumber);
    }

    final body = {
      ..._body(pigeon),
      if (newImages.isNotEmpty) 'images': newImages,
      if (videoUrl != null && videoUrl.isNotEmpty) 'video_url': videoUrl,
    };

    final response =
        await _dio.patch(ApiConstants.birdDetail(id), data: body);
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBird(int id) async {
    await _dio.delete(ApiConstants.birdDetail(id));
  }
}
