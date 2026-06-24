import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../pigeon_model.dart';
import 'pigeon_remote_datasource.dart';

class RealPigeonRemoteDataSource implements PigeonRemoteDataSource {
  final DioClient _dio;

  const RealPigeonRemoteDataSource(this._dio);

  // ── Cloudinary helpers ──────────────────────────────────────────────────────

  // Uploads local paths; passes through existing https:// URLs unchanged.
  // Returns the full ordered media list for all image paths.
  Future<List<Map<String, dynamic>>> _buildImageMedia(
      List<String> paths, String ringNumber) async {
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < paths.length; i++) {
      final path = paths[i];
      final String? url;
      if (path.startsWith('http')) {
        url = path;
      } else {
        url = await CloudinaryService.uploadImage(path, ringNumber);
      }
      if (url != null) {
        result.add({
          'media_url': url,
          'media_type': 'image',
          'is_primary': i == 0,
          'order': i,
        });
      }
    }
    return result;
  }

  // ── Shared body builder ─────────────────────────────────────────────────────

  Map<String, dynamic> _body(PigeonModel pigeon, {bool includeStatus = false}) => {
        'name': pigeon.name.isNotEmpty ? pigeon.name : pigeon.ringNumber,
        'ring_number': pigeon.ringNumber,
        'title': pigeon.name.isNotEmpty ? pigeon.name : pigeon.ringNumber,
        'gender': pigeon.gender.apiValue,
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
        if (includeStatus) 'status': pigeon.status,
        if (pigeon.fatherId != null) 'father': pigeon.fatherId,
        if (pigeon.motherId != null) 'mother': pigeon.motherId,
      };

  // ── Public API ──────────────────────────────────────────────────────────────

  @override
  Future<PigeonModel> saveBird(PigeonModel pigeon) async {
    final imageMedia = await _buildImageMedia(
        pigeon.photoPaths, pigeon.ringNumber);

    String? videoUrl;
    if (pigeon.videoPath != null) {
      videoUrl = await CloudinaryService.uploadVideo(
          pigeon.videoPath!, pigeon.ringNumber);
    }

    final mediaList = <Map<String, dynamic>>[...imageMedia];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      mediaList.add({
        'media_url': videoUrl,
        'media_type': 'video',
        'is_primary': false,
        'order': mediaList.length,
      });
    }

    final body = <String, dynamic>{
      ..._body(pigeon),
      'is_for_auction': false,
      'category': 'bird',
      'count': 1,
      if (mediaList.isNotEmpty) 'media': mediaList,
    };

    final response = await _dio.post(ApiConstants.birds, data: body);
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PigeonModel> updateBird(int id, PigeonModel pigeon) async {
    // _buildImageMedia passes through existing https:// URLs and uploads local paths.
    // Sends the full ordered list so the backend replaces the media set correctly.
    final imageMedia = await _buildImageMedia(
        pigeon.photoPaths, pigeon.ringNumber);

    String? videoUrl = pigeon.videoPath;
    if (pigeon.videoPath != null && !pigeon.videoPath!.startsWith('http')) {
      videoUrl = await CloudinaryService.uploadVideo(
          pigeon.videoPath!, pigeon.ringNumber);
    }

    final mediaList = <Map<String, dynamic>>[...imageMedia];
    if (videoUrl != null && videoUrl.isNotEmpty) {
      mediaList.add({
        'media_url': videoUrl,
        'media_type': 'video',
        'is_primary': false,
        'order': mediaList.length,
      });
    }

    final body = <String, dynamic>{
      ..._body(pigeon, includeStatus: true),
      if (mediaList.isNotEmpty) 'media': mediaList,
    };

    final response =
        await _dio.patch(ApiConstants.birdDetail(id), data: body);
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBird(int id) async {
    await _dio.delete(ApiConstants.birdDetail(id));
  }

  @override
  Future<PigeonModel> fetchPublicBird(String publicId) async {
    final response = await _dio.get(ApiConstants.publicBird(publicId));
    return PigeonModel.fromJson(response.data as Map<String, dynamic>);
  }
}
