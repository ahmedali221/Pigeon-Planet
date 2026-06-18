import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markRead(int id);
}

class RealNotificationsRemoteDataSource implements NotificationsRemoteDataSource {
  final DioClient _dio;

  const RealNotificationsRemoteDataSource(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    final data = response.data;
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConstants.notificationsUnreadCount);
    final data = response.data;
    if (data is int) return data;
    if (data is Map) return (data['count'] as num?)?.toInt() ?? 0;
    return 0;
  }

  @override
  Future<void> markRead(int id) async {
    await _dio.post(ApiConstants.notificationRead(id));
  }
}
