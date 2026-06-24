part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, loaded, loadingMore, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isActing;
  final String? actionError;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.isActing = false,
    this.actionError,
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 1,
  });

  int get computedUnreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isActing,
    String? actionError,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        unreadCount: unreadCount ?? this.unreadCount,
        isActing: isActing ?? this.isActing,
        actionError: actionError ?? this.actionError,
        errorMessage: errorMessage ?? this.errorMessage,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
      );

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        isActing,
        actionError,
        errorMessage,
        hasMore,
        currentPage,
      ];
}
