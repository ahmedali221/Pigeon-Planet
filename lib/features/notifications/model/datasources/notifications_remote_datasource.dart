import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../notification_model.dart';

typedef NotificationsPageResult = ({
  List<NotificationModel> notifications,
  bool hasMore,
});

abstract class NotificationsRemoteDataSource {
  Future<NotificationsPageResult> getNotifications({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markRead(int id);
  Future<int> markAllRead();
}

class RealNotificationsRemoteDataSource implements NotificationsRemoteDataSource {
  final DioClient _dio;

  const RealNotificationsRemoteDataSource(this._dio);

  @override
  Future<NotificationsPageResult> getNotifications({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'page': page},
    );
    final data = response.data;
    List<dynamic> items;
    bool hasMore = false;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
      hasMore = data['next'] != null;
    } else if (data is List) {
      items = data;
    } else {
      return (notifications: <NotificationModel>[], hasMore: false);
    }
    final notifications = items
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (notifications: notifications, hasMore: hasMore);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConstants.notificationsUnreadCount);
    final data = response.data;
    if (data is int) return data;
    if (data is Map) {
      return (data['unread_count'] as num?)?.toInt() ??
          (data['count'] as num?)?.toInt() ??
          0;
    }
    return 0;
  }

  @override
  Future<void> markRead(int id) async {
    await _dio.post(ApiConstants.notificationMarkRead(id));
  }

  @override
  Future<int> markAllRead() async {
    final response = await _dio.post(ApiConstants.notificationsMarkAllRead);
    final data = response.data;
    if (data is Map) return (data['updated_count'] as num?)?.toInt() ?? 0;
    return 0;
  }
}
