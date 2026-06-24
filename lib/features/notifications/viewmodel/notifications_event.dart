part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefreshRequested extends NotificationsEvent {
  const NotificationsRefreshRequested();
}

class NotificationsLoadMoreRequested extends NotificationsEvent {
  const NotificationsLoadMoreRequested();
}

class NotificationMarkReadRequested extends NotificationsEvent {
  final int id;
  const NotificationMarkReadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class NotificationMarkAllReadRequested extends NotificationsEvent {
  const NotificationMarkAllReadRequested();
}
