import '../../../../core/network/dio_client.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchNotifications();

  Future<void> markRead(int id);
}

class RealNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  const RealNotificationsRemoteDataSource(DioClient _);

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    return [];
  }

  @override
  Future<void> markRead(int id) async {
    return;
  }
}
