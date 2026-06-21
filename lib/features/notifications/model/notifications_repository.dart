import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'notification_model.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markRead(int id);
  Future<Either<Failure, int>> markAllRead();
}
