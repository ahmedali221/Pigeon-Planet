import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/model/datasources/points_remote_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class BuyWithCashbackEvent extends Equatable {
  const BuyWithCashbackEvent();
  @override
  List<Object?> get props => [];
}

class BuyWithCashbackRequested extends BuyWithCashbackEvent {
  final double cashbackAmount;
  const BuyWithCashbackRequested(this.cashbackAmount);
  @override
  List<Object?> get props => [cashbackAmount];
}

// ── States ────────────────────────────────────────────────────────────────────

enum BuyWithCashbackStatus { idle, loading, success, error }

class BuyWithCashbackState extends Equatable {
  final BuyWithCashbackStatus status;
  final int? pointsAwarded;
  final double? newCashbackBalance;
  final int? newPointBalance;
  final String? errorMessage;

  const BuyWithCashbackState({
    this.status = BuyWithCashbackStatus.idle,
    this.pointsAwarded,
    this.newCashbackBalance,
    this.newPointBalance,
    this.errorMessage,
  });

  BuyWithCashbackState copyWith({
    BuyWithCashbackStatus? status,
    int? pointsAwarded,
    double? newCashbackBalance,
    int? newPointBalance,
    String? errorMessage,
    bool clearError = false,
  }) =>
      BuyWithCashbackState(
        status: status ?? this.status,
        pointsAwarded: pointsAwarded ?? this.pointsAwarded,
        newCashbackBalance: newCashbackBalance ?? this.newCashbackBalance,
        newPointBalance: newPointBalance ?? this.newPointBalance,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props =>
      [status, pointsAwarded, newCashbackBalance, newPointBalance, errorMessage];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class BuyWithCashbackBloc
    extends Bloc<BuyWithCashbackEvent, BuyWithCashbackState> {
  final PointsRemoteDataSource _datasource;

  BuyWithCashbackBloc({required PointsRemoteDataSource datasource})
      : _datasource = datasource,
        super(const BuyWithCashbackState()) {
    on<BuyWithCashbackRequested>(_onRequested);
  }

  Future<void> _onRequested(
    BuyWithCashbackRequested event,
    Emitter<BuyWithCashbackState> emit,
  ) async {
    emit(state.copyWith(
      status: BuyWithCashbackStatus.loading,
      clearError: true,
    ));
    try {
      final key = 'buy-${DateTime.now().microsecondsSinceEpoch}';
      final result = await _datasource.buyWithCashback(
        cashbackAmount: event.cashbackAmount,
        idempotencyKey: key,
      );
      emit(state.copyWith(
        status: BuyWithCashbackStatus.success,
        pointsAwarded: result.pointsAwarded,
        newCashbackBalance: result.cashbackBalance,
        newPointBalance: result.pointBalance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BuyWithCashbackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
