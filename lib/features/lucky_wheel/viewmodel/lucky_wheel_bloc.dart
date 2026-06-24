import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/datasources/lucky_wheel_datasource.dart';
import '../model/lucky_wheel_current_model.dart';
import '../model/lucky_wheel_segment_model.dart';
import '../model/wheel_prize_model.dart';
import '../model/wheel_spin_result_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class LuckyWheelEvent extends Equatable {
  const LuckyWheelEvent();
  @override
  List<Object?> get props => [];
}

class LuckyWheelLoadRequested extends LuckyWheelEvent {
  /// Kept for the info-header display; does not affect BE call.
  final bool isSeller;
  const LuckyWheelLoadRequested({this.isSeller = false});
  @override
  List<Object?> get props => [isSeller];
}

class LuckyWheelSpinRequested extends LuckyWheelEvent {
  const LuckyWheelSpinRequested();
}

// ── States ────────────────────────────────────────────────────────────────────

enum LuckyWheelStatus { initial, loading, ready, spinning, error }

class LuckyWheelState extends Equatable {
  final LuckyWheelStatus status;
  final LuckyWheelCurrentModel? current;
  final WheelSpinResultModel? spinResult;
  final int? winnerIndex;
  final bool hasSpun;
  final bool isSeller;
  final String? errorMessage;

  const LuckyWheelState({
    this.status = LuckyWheelStatus.initial,
    this.current,
    this.spinResult,
    this.winnerIndex,
    this.hasSpun = false,
    this.isSeller = false,
    this.errorMessage,
  });

  List<WheelPrizeModel> get prizes {
    final segments = current?.segments ?? const <LuckyWheelSegmentModel>[];
    return segments
        .map((s) => WheelPrizeModel(
              type: s.prizeType,
              label: s.label,
              emoji: s.emoji,
              color: s.color,
              weight: 1,
              isEnabled: true,
              description: s.description,
            ))
        .toList();
  }

  LuckyWheelState copyWith({
    LuckyWheelStatus? status,
    LuckyWheelCurrentModel? current,
    WheelSpinResultModel? spinResult,
    int? winnerIndex,
    bool? hasSpun,
    bool? isSeller,
    String? errorMessage,
    bool clearError = false,
  }) =>
      LuckyWheelState(
        status: status ?? this.status,
        current: current ?? this.current,
        spinResult: spinResult ?? this.spinResult,
        winnerIndex: winnerIndex ?? this.winnerIndex,
        hasSpun: hasSpun ?? this.hasSpun,
        isSeller: isSeller ?? this.isSeller,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        current,
        spinResult,
        winnerIndex,
        hasSpun,
        isSeller,
        errorMessage,
      ];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class LuckyWheelBloc extends Bloc<LuckyWheelEvent, LuckyWheelState> {
  final LuckyWheelDataSource _datasource;
  LuckyWheelBloc({required LuckyWheelDataSource datasource})
      : _datasource = datasource,
        super(const LuckyWheelState()) {
    on<LuckyWheelLoadRequested>(_onLoad);
    on<LuckyWheelSpinRequested>(_onSpin);
  }

  Future<void> _onLoad(
    LuckyWheelLoadRequested event,
    Emitter<LuckyWheelState> emit,
  ) async {
    emit(state.copyWith(
      status: LuckyWheelStatus.loading,
      isSeller: event.isSeller,
      clearError: true,
    ));
    try {
      final current = await _datasource.fetchCurrent();
      emit(state.copyWith(
        status: LuckyWheelStatus.ready,
        current: current,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LuckyWheelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSpin(
    LuckyWheelSpinRequested event,
    Emitter<LuckyWheelState> emit,
  ) async {
    final current = state.current;
    if (state.hasSpun ||
        current == null ||
        !current.eligible ||
        current.segments.isEmpty) {
      return;
    }

    final segmentIds = current.segments.map((s) => s.id).toList();
    final idempotencyKey = 'spin-${DateTime.now().microsecondsSinceEpoch}';

    emit(state.copyWith(status: LuckyWheelStatus.spinning));
    try {
      final result = await _datasource.spin(
        idempotencyKey: idempotencyKey,
        segmentIds: segmentIds,
      );
      final updatedCurrent = state.current?.copyWith(
        remainingAttempts: result.remainingAttempts,
      );
      emit(state.copyWith(
        status: LuckyWheelStatus.spinning,
        current: updatedCurrent,
        spinResult: result,
        winnerIndex: result.winnerIndex,
        hasSpun: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LuckyWheelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
