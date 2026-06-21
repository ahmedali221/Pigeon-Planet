import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/model/datasources/points_remote_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BadgesEvent extends Equatable {
  const BadgesEvent();
  @override
  List<Object?> get props => [];
}

class BadgesLoadRequested extends BadgesEvent {
  const BadgesLoadRequested();
}

class BadgesIncludeExpiredToggled extends BadgesEvent {
  const BadgesIncludeExpiredToggled();
}

// ── States ────────────────────────────────────────────────────────────────────

enum BadgesStatus { initial, loading, loaded, error }

class BadgesState extends Equatable {
  final BadgesStatus status;
  final List<BadgeAwardModel> badges;
  final bool includeExpired;
  final String? errorMessage;

  const BadgesState({
    this.status = BadgesStatus.initial,
    this.badges = const [],
    this.includeExpired = false,
    this.errorMessage,
  });

  BadgesState copyWith({
    BadgesStatus? status,
    List<BadgeAwardModel>? badges,
    bool? includeExpired,
    String? errorMessage,
    bool clearError = false,
  }) =>
      BadgesState(
        status: status ?? this.status,
        badges: badges ?? this.badges,
        includeExpired: includeExpired ?? this.includeExpired,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, badges, includeExpired, errorMessage];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class BadgesBloc extends Bloc<BadgesEvent, BadgesState> {
  final PointsRemoteDataSource _datasource;

  BadgesBloc({required PointsRemoteDataSource datasource})
      : _datasource = datasource,
        super(const BadgesState()) {
    on<BadgesLoadRequested>(_onLoad);
    on<BadgesIncludeExpiredToggled>(_onToggleExpired);
  }

  Future<void> _onLoad(
    BadgesLoadRequested event,
    Emitter<BadgesState> emit,
  ) async {
    emit(state.copyWith(status: BadgesStatus.loading, clearError: true));
    try {
      final badges = await _datasource.fetchMyBadges(
        includeExpired: state.includeExpired,
      );
      emit(state.copyWith(status: BadgesStatus.loaded, badges: badges));
    } catch (e) {
      emit(state.copyWith(
        status: BadgesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggleExpired(
    BadgesIncludeExpiredToggled event,
    Emitter<BadgesState> emit,
  ) async {
    final next = !state.includeExpired;
    emit(state.copyWith(
      includeExpired: next,
      status: BadgesStatus.loading,
      clearError: true,
    ));
    try {
      final badges = await _datasource.fetchMyBadges(includeExpired: next);
      emit(state.copyWith(status: BadgesStatus.loaded, badges: badges));
    } catch (e) {
      emit(state.copyWith(
        status: BadgesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
