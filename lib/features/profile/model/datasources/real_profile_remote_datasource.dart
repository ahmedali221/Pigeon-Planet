import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../profile_model.dart';
import 'profile_remote_datasource.dart';

class RealProfileRemoteDataSource implements ProfileRemoteDataSource {
  final DioClient _dio;
  const RealProfileRemoteDataSource(this._dio);

  @override
  Future<ProfileModel> getProfile(String profileType) async {
    final endpoint = profileType == 'Seller'
        ? ApiConstants.mySellers
        : ApiConstants.myCustomers;
    final response = await _dio.get(endpoint);
    final data = response.data;
    List<dynamic> results;
    if (data is Map && data.containsKey('results')) {
      results = data['results'] as List<dynamic>;
    } else if (data is List) {
      results = data;
    } else {
      results = [];
    }
    if (results.isEmpty) {
      throw Exception('لم يتم العثور على الملف الشخصي');
    }
    return ProfileModel.fromJson(results.first as Map<String, dynamic>);
  }

  @override
  Future<List<ProfileModel>> fetchAllSellerProfiles() async {
    final response = await _dio.get(ApiConstants.mySellers);
    final data = response.data;
    final List list;
    if (data is Map && data.containsKey('results')) {
      list = data['results'] as List;
    } else if (data is List) {
      list = data;
    } else {
      return [];
    }
    return list
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createRoom({
    required String nickname,
    required String country,
    required String currency,
  }) async {
    await _dio.post(
      ApiConstants.mySellers,
      data: {
        'nickname': nickname,
        'country': country,
        'currency': currency,
      },
    );
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final endpoint = profile.isSeller
        ? ApiConstants.sellerDetail(profile.id)
        : ApiConstants.customerDetail(profile.id);

    final body = profile.isSeller
        ? {
            'nickname': profile.nickname ?? '',
            'country': profile.country,
            'currency': profile.currency,
          }
        : {
            'country': profile.country,
            'currency': profile.currency,
          };

    final response = await _dio.patch(endpoint, data: body);
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProfile(ProfileModel profile) async {
    final endpoint = profile.isSeller
        ? ApiConstants.sellerDetail(profile.id)
        : ApiConstants.customerDetail(profile.id);
    await _dio.delete(endpoint);
  }

  @override
  Future<ProfileModel> uploadProfilePhoto({
    required int profileId,
    required String profileType,
    required String filePath,
  }) async {
    final endpoint = profileType == 'Seller'
        ? ApiConstants.sellerAvatar(profileId)
        : ApiConstants.customerAvatar(profileId);

    final avatarUrl = await CloudinaryService.uploadAvatar(
      filePath,
      '${profileType.toLowerCase()}_$profileId',
    );
    if (avatarUrl == null) throw Exception('Failed to upload avatar');

    final response = await _dio.patch(endpoint, data: {'avatar': avatarUrl});
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
