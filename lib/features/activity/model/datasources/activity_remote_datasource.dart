import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class ActivityRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchActivity({String? profileType});
}

class RealActivityRemoteDataSource implements ActivityRemoteDataSource {
  final DioClient _dio;

  const RealActivityRemoteDataSource(this._dio);

  @override
  Future<List<Map<String, dynamic>>> fetchActivity({String? profileType}) async {
    final query = <String, dynamic>{};
    if (profileType != null && profileType.isNotEmpty) {
      query['profile'] = profileType;
    }
    final response = await _dio.get(
      ApiConstants.coreActivity,
      queryParameters: query.isEmpty ? null : query,
    );
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }
}
