import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/badge_model.dart';
import '../model/datasources/loyalty_remote_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BadgesEvent extends Equatable {
  const BadgesEvent();
  @override
  List<Object?> get props => [];
}

class BadgesLoadRequested extends BadgesEvent {
  const BadgesLoadRequested();
}

// ── States ────────────────────────────────────────────────────────────────────

enum BadgesStatus { initial, loading, loaded, error }

class BadgesState extends Equatable {
  final BadgesStatus status;
  final List<BadgeModel> badges;
  final String? errorMessage;

  const BadgesState({
    this.status = BadgesStatus.initial,
    this.badges = const [],
    this.errorMessage,
  });

  BadgesState copyWith({
    BadgesStatus? status,
    List<BadgeModel>? badges,
    String? errorMessage,
    bool clearError = false,
  }) =>
      BadgesState(
        status: status ?? this.status,
        badges: badges ?? this.badges,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, badges, errorMessage];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class BadgesBloc extends Bloc<BadgesEvent, BadgesState> {
  final LoyaltyRemoteDataSource _datasource;

  BadgesBloc({required LoyaltyRemoteDataSource datasource})
      : _datasource = datasource,
        super(const BadgesState()) {
    on<BadgesLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(BadgesLoadRequested event, Emitter<BadgesState> emit) async {
    emit(state.copyWith(status: BadgesStatus.loading, clearError: true));
    try {
      final badges = await _datasource.fetchMyBadges();
      emit(state.copyWith(status: BadgesStatus.loaded, badges: badges));
    } catch (e) {
      emit(state.copyWith(
        status: BadgesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
