import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/notification_model.dart';
import '../model/notifications_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class _SilentPollTick extends NotificationsEvent {
  const _SilentPollTick();
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;
  Timer? _pollTimer;

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefreshRequested>(_onRefresh);
    on<NotificationsLoadMoreRequested>(_onLoadMore);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<_SilentPollTick>(_onSilentPoll);
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load(emit);
    _pollTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) add(const _SilentPollTick());
    });
  }

  Future<void> _onRefresh(
    NotificationsRefreshRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load(emit);
  }

  Future<void> _onLoadMore(
    NotificationsLoadMoreRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!state.hasMore || state.status == NotificationsStatus.loadingMore) {
      return;
    }
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: NotificationsStatus.loadingMore));
    final result = await _repository.getNotifications(page: nextPage);
    result.fold(
      (f) => emit(state.copyWith(status: NotificationsStatus.loaded)),
      (page) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: [...state.notifications, ...page.notifications],
        hasMore: page.hasMore,
        currentPage: nextPage,
      )),
    );
  }

  Future<void> _onSilentPoll(
    _SilentPollTick event,
    Emitter<NotificationsState> emit,
  ) async {
    final countResult = await _repository.getUnreadCount();
    countResult.fold(
      (_) {},
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> _load(Emitter<NotificationsState> emit) async {
    final listResult = await _repository.getNotifications(page: 1);
    final countResult = await _repository.getUnreadCount();

    final unreadCount = countResult.fold((_) => 0, (c) => c);

    listResult.fold(
      (f) => emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: f.message,
      )),
      (page) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: page.notifications,
        hasMore: page.hasMore,
        currentPage: 1,
        unreadCount: unreadCount,
      )),
    );
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
      hasMore: state.hasMore,
      currentPage: state.currentPage,
    ));

    final result = await _repository.markRead(event.id);
    result.fold(
      (f) => emit(state.copyWith(
        notifications: before,
        isActing: false,
        actionError: f.message,
        unreadCount: state.unreadCount + 1,
      )),
      (_) => emit(state.copyWith(isActing: false)),
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
      (_) => emit(state.copyWith(isActing: false)),
    );
  }
}
