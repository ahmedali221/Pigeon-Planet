import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/datasources/lucky_wheel_datasource.dart';
import '../model/wheel_prize_model.dart';
import '../model/wheel_spin_result_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class LuckyWheelEvent extends Equatable {
  const LuckyWheelEvent();
  @override
  List<Object?> get props => [];
}

class LuckyWheelLoadRequested extends LuckyWheelEvent {
  final bool isSeller;
  const LuckyWheelLoadRequested({required this.isSeller});
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
  final List<WheelPrizeModel> prizes;
  final WheelSpinResultModel? spinResult;
  final int? winnerIndex;
  final bool hasSpun;
  final bool isSeller;
  final String? errorMessage;

  const LuckyWheelState({
    this.status = LuckyWheelStatus.initial,
    this.prizes = const [],
    this.spinResult,
    this.winnerIndex,
    this.hasSpun = false,
    this.isSeller = false,
    this.errorMessage,
  });

  LuckyWheelState copyWith({
    LuckyWheelStatus? status,
    List<WheelPrizeModel>? prizes,
    WheelSpinResultModel? spinResult,
    int? winnerIndex,
    bool? hasSpun,
    bool? isSeller,
    String? errorMessage,
    bool clearError = false,
  }) =>
      LuckyWheelState(
        status: status ?? this.status,
        prizes: prizes ?? this.prizes,
        spinResult: spinResult ?? this.spinResult,
        winnerIndex: winnerIndex ?? this.winnerIndex,
        hasSpun: hasSpun ?? this.hasSpun,
        isSeller: isSeller ?? this.isSeller,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        prizes,
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
  final _random = Random();

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
      final prizes =
          await _datasource.fetchPrizes(isSeller: event.isSeller);
      emit(state.copyWith(
        status: LuckyWheelStatus.ready,
        prizes: prizes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LuckyWheelStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSpin(
    LuckyWheelSpinRequested event,
    Emitter<LuckyWheelState> emit,
  ) {
    if (state.hasSpun || state.prizes.isEmpty) return;

    final winnerIdx = _pickWinner(state.prizes);
    final winner = state.prizes[winnerIdx];

    final result = WheelSpinResultModel(
      prizeType: winner.type,
      prizeLabel: winner.label,
      prizeEmoji: winner.emoji,
      prizeColor: winner.color,
      description: winner.description,
      winnerIndex: winnerIdx,
    );

    emit(state.copyWith(
      status: LuckyWheelStatus.spinning,
      winnerIndex: winnerIdx,
      spinResult: result,
      hasSpun: true,
    ));
  }

  /// Weighted random selection across enabled prizes.
  int _pickWinner(List<WheelPrizeModel> prizes) {
    final enabled = prizes.where((p) => p.isEnabled).toList();
    if (enabled.isEmpty) return 0;

    final totalWeight = enabled.fold(0, (sum, p) => sum + p.weight);
    int pick = _random.nextInt(totalWeight);

    for (int i = 0; i < prizes.length; i++) {
      if (!prizes[i].isEnabled) continue;
      pick -= prizes[i].weight;
      if (pick < 0) return i;
    }
    return prizes.indexWhere((p) => p.isEnabled);
  }
}
