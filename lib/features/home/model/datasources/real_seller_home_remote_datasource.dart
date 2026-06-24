import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../announcement_model.dart';
import '../customer_home_summary.dart';
import '../seller_home_summary.dart';
import '../seller_model.dart';
import 'seller_home_remote_datasource.dart';

class RealSellerHomeRemoteDataSource implements SellerHomeRemoteDataSource {
  final DioClient _dio;

  const RealSellerHomeRemoteDataSource(this._dio);

  @override
  Future<SellerHomeSummary?> fetchHomeSummary() async {
    try {
      final response = await _dio.get(ApiConstants.insightsSellerHome);
      final data = response.data;
      if (data == null) return null;
      return SellerHomeSummary.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CustomerHomeSummary?> fetchCustomerHomeSummary() async {
    return null;
  }

  @override
  Future<int> fetchUnreadNotificationCount() async {
    try {
      final response =
          await _dio.get(ApiConstants.notificationsUnreadCount);
      final data = response.data;
      if (data is int) return data;
      if (data is Map) return (data['unread_count'] as num?)?.toInt() ?? 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<List<SellerModel>> fetchSellers({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.feedSellersList,
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

  @override
  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    final response = await _dio.get(ApiConstants.announcements);
    final data = response.data;
    if (data == null) return [];
    final List<dynamic> items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((json) => AnnouncementModel.fromJson(json as Map<String, dynamic>))
        .where((announcement) => announcement.isActive)
        .toList();
  }
}
