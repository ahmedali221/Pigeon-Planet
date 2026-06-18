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
    final listFut = _repository.getNotifications();
    final countFut = _repository.getUnreadCount();

    final listResult = await listFut;
    final countResult = await countFut;

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
    // Optimistic update — mark locally first
    final updated = state.notifications
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
      (f) {
        // Roll back optimistic update on failure
        emit(state.copyWith(
          notifications: state.notifications
              .map((n) => n.id == event.id
                  ? NotificationModel(
                      id: n.id,
                      kind: n.kind,
                      title: n.title,
                      body: n.body,
                      isRead: false,
                      profileType: n.profileType,
                      created: n.created,
                    )
                  : n)
              .toList(),
          isActing: false,
          actionError: f.message,
          unreadCount: state.unreadCount + 1,
        ));
      },
      (_) => emit(state.copyWith(isActing: false)),
    );
  }
}
