import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/promotions_repository.dart';
import 'promotions_event.dart';
import 'promotions_state.dart';

export 'promotions_event.dart';
export 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final PromotionsRepository _repository;

  PromotionsBloc({required PromotionsRepository repository})
      : _repository = repository,
        super(const PromotionsState()) {
    on<PromotionsStarted>(_onStarted);
    on<PromotionsRefreshed>(_onRefreshed);
  }

  Future<void> _onStarted(
    PromotionsStarted event,
    Emitter<PromotionsState> emit,
  ) async {
    if (state.status == PromotionsStatus.loaded) return;
    await _load(emit);
  }

  Future<void> _onRefreshed(
    PromotionsRefreshed event,
    Emitter<PromotionsState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<PromotionsState> emit) async {
    emit(state.copyWith(status: PromotionsStatus.loading, errorMessage: null));

    final balanceResult = await _repository.getCashbackBalance();
    final txResult = await _repository.getCashbackTransactions();

    final balance = balanceResult.fold((_) => state.balance, (b) => b);

    txResult.fold(
      (failure) => emit(state.copyWith(
        status: PromotionsStatus.error,
        balance: balance,
        errorMessage: failure.message,
      )),
      (transactions) => emit(state.copyWith(
        status: PromotionsStatus.loaded,
        balance: balance,
        transactions: transactions,
      )),
    );
  }
}
