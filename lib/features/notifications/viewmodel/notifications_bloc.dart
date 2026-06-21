import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/notification_model.dart';
import '../model/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefreshRequested>(_onRefresh);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefresh(
    NotificationsRefreshRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load(emit);
  }

  Future<void> _load(Emitter<NotificationsState> emit) async {
    final listResult = await _repository.getNotifications();
    final countResult = await _repository.getUnreadCount();

    final notifications = listResult.fold((_) => <NotificationModel>[], (l) => l);
    final unreadCount = countResult.fold((_) => 0, (c) => c);

    if (listResult.isLeft() && notifications.isEmpty) {
      final failure = listResult.fold((f) => f, (_) => null);
      emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: failure?.message,
      ));
    } else {
      emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final before = state.notifications;
    final updated = before
        .map((n) => n.id == event.id ? n.markRead() : n)
        .toList();
    emit(NotificationsState(
      status: state.status,
      notifications: updated,
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      isActing: true,
    ));

    final result = await _repository.markRead(event.id);
    result.fold(
      (f) => emit(state.copyWith(
        notifications: before,
        isActing: false,
        actionError: f.message,
        unreadCount: state.unreadCount + 1,
      )),
      (_) => emit(state.copyWith(isActing: false, actionError: null)),
    );
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final before = state.notifications;
    final allRead = before.map((n) => n.markRead()).toList();
    emit(state.copyWith(notifications: allRead, unreadCount: 0, isActing: true));

    final result = await _repository.markAllRead();
    result.fold(
      (f) => emit(state.copyWith(
        notifications: before,
        unreadCount: before.where((n) => !n.isRead).length,
        isActing: false,
        actionError: f.message,
      )),
      (_) => emit(state.copyWith(isActing: false, actionError: null)),
    );
  }
}
