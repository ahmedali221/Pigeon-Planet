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
    on<PromotionsOffersRequested>(_onOffersRequested);
    on<PromotionsTxLoadMore>(_onTxLoadMore);
    on<PromotionsGrantsLoadMore>(_onGrantsLoadMore);
  }

  Future<void> _onStarted(
    PromotionsStarted event,
    Emitter<PromotionsState> emit,
  ) async {
    if (state.status == PromotionsStatus.loaded) return;
    await _loadWallet(emit, page: 1, reset: true);
  }

  Future<void> _onRefreshed(
    PromotionsRefreshed event,
    Emitter<PromotionsState> emit,
  ) async {
    await _loadWallet(emit, page: 1, reset: true);
  }

  Future<void> _onOffersRequested(
    PromotionsOffersRequested event,
    Emitter<PromotionsState> emit,
  ) async {
    if (state.offersLoading) return;
    emit(state.copyWith(offersLoading: true, clearError: true));

    final discountResult = await _repository.getDiscountOffers();
    final cashbackResult = await _repository.getCashbackOffers();
    final grantsResult = await _repository.getMyGrants(page: 1);

    final discountOffers = discountResult.fold((_) => state.discountOffers, (v) => v);
    final cashbackOffers = cashbackResult.fold((_) => state.cashbackOffers, (v) => v);
    final grantsData = grantsResult.fold(
      (_) => (items: state.grants, hasMore: state.hasMoreGrants),
      (v) => v,
    );

    emit(state.copyWith(
      offersLoading: false,
      discountOffers: discountOffers,
      cashbackOffers: cashbackOffers,
      grants: grantsData.items,
      hasMoreGrants: grantsData.hasMore,
      grantsPage: 1,
    ));
  }

  Future<void> _onTxLoadMore(
    PromotionsTxLoadMore event,
    Emitter<PromotionsState> emit,
  ) async {
    if (state.loadingMoreTx || !state.hasMoreTx) return;
    emit(state.copyWith(loadingMoreTx: true));

    final nextPage = state.txPage + 1;
    final result = await _repository.getCashbackTransactions(page: nextPage);
    result.fold(
      (_) => emit(state.copyWith(loadingMoreTx: false)),
      (data) => emit(state.copyWith(
        loadingMoreTx: false,
        transactions: [...state.transactions, ...data.items],
        hasMoreTx: data.hasMore,
        txPage: nextPage,
      )),
    );
  }

  Future<void> _onGrantsLoadMore(
    PromotionsGrantsLoadMore event,
    Emitter<PromotionsState> emit,
  ) async {
    if (state.loadingMoreGrants || !state.hasMoreGrants) return;
    emit(state.copyWith(loadingMoreGrants: true));

    final nextPage = state.grantsPage + 1;
    final result = await _repository.getMyGrants(page: nextPage);
    result.fold(
      (_) => emit(state.copyWith(loadingMoreGrants: false)),
      (data) => emit(state.copyWith(
        loadingMoreGrants: false,
        grants: [...state.grants, ...data.items],
        hasMoreGrants: data.hasMore,
        grantsPage: nextPage,
      )),
    );
  }

  Future<void> _loadWallet(
    Emitter<PromotionsState> emit, {
    required int page,
    required bool reset,
  }) async {
    emit(state.copyWith(
      status: reset ? PromotionsStatus.loading : state.status,
      clearError: true,
    ));

    final balanceResult = await _repository.getCashbackBalance();
    final txResult = await _repository.getCashbackTransactions(page: page);

    final balance = balanceResult.fold((_) => state.balance, (b) => b);

    txResult.fold(
      (failure) => emit(state.copyWith(
        status: PromotionsStatus.error,
        balance: balance,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: PromotionsStatus.loaded,
        balance: balance,
        transactions: reset ? data.items : [...state.transactions, ...data.items],
        hasMoreTx: data.hasMore,
        txPage: page,
      )),
    );
  }
}
