import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../badge_model.dart';
import 'loyalty_remote_datasource.dart';

class RealLoyaltyRemoteDataSource implements LoyaltyRemoteDataSource {
  final DioClient _dio;

  const RealLoyaltyRemoteDataSource(this._dio);

  @override
  Future<List<BadgeModel>> fetchMyBadges() async {
    final response = await _dio.get(ApiConstants.loyaltyMyBadges);
    final data = response.data;
    if (data == null) return [];
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((j) => BadgeModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
