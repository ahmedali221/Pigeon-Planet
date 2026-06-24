import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/datasources/lucky_wheel_datasource.dart';
import '../model/lucky_wheel_spin_history_model.dart';

enum LuckyWheelHistoryStatus { initial, loading, loaded, loadingMore, error }

class LuckyWheelHistoryState {
  final LuckyWheelHistoryStatus status;
  final List<LuckyWheelSpinHistoryModel> spins;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  const LuckyWheelHistoryState({
    this.status = LuckyWheelHistoryStatus.initial,
    this.spins = const [],
    this.hasMore = false,
    this.currentPage = 1,
    this.errorMessage,
  });

  LuckyWheelHistoryState copyWith({
    LuckyWheelHistoryStatus? status,
    List<LuckyWheelSpinHistoryModel>? spins,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) =>
      LuckyWheelHistoryState(
        status: status ?? this.status,
        spins: spins ?? this.spins,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class LuckyWheelHistoryCubit extends Cubit<LuckyWheelHistoryState> {
  final LuckyWheelDataSource _datasource;

  LuckyWheelHistoryCubit(this._datasource)
      : super(const LuckyWheelHistoryState());

  Future<void> load() async {
    emit(state.copyWith(
      status: LuckyWheelHistoryStatus.loading,
      spins: const [],
      currentPage: 1,
    ));
    try {
      final result = await _datasource.fetchSpinHistory(page: 1);
      emit(state.copyWith(
        status: LuckyWheelHistoryStatus.loaded,
        spins: result.spins,
        hasMore: result.hasMore,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LuckyWheelHistoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == LuckyWheelHistoryStatus.loadingMore) {
      return;
    }
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: LuckyWheelHistoryStatus.loadingMore));
    try {
      final result = await _datasource.fetchSpinHistory(page: nextPage);
      emit(state.copyWith(
        status: LuckyWheelHistoryStatus.loaded,
        spins: [...state.spins, ...result.spins],
        hasMore: result.hasMore,
        currentPage: nextPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LuckyWheelHistoryStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }
}
