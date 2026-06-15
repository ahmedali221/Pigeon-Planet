import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../customer_home_summary.dart';
import '../seller_home_summary.dart';
import '../seller_model.dart';
import 'seller_home_remote_datasource.dart';

class RealSellerHomeRemoteDataSource implements SellerHomeRemoteDataSource {
  final DioClient _dio;

  const RealSellerHomeRemoteDataSource(this._dio);

  @override
  Future<SellerHomeSummary?> fetchHomeSummary() async {
    return null;
  }

  @override
  Future<CustomerHomeSummary?> fetchCustomerHomeSummary() async {
    return null;
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    return 0;
  }

  @override
  Future<List<SellerModel>> fetchSellers({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.mySellers,
      queryParameters: {'page': page},
    );
    final data = response.data;
    if (data == null) return [];
    final List<dynamic> items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((j) => SellerModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
