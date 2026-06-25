import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/clocks_repository.dart';
import '../model/electronic_clock_model.dart';

part 'clocks_event.dart';
part 'clocks_state.dart';

class ClocksBloc extends Bloc<ClocksEvent, ClocksState> {
  final ClocksRepository _repository;

  ClocksBloc({required ClocksRepository repository})
      : _repository = repository,
        super(const ClocksState()) {
    on<ClocksListLoaded>(_onListLoaded);
    on<ClocksSearchChanged>(_onSearchChanged);
    on<ClockDetailRequested>(_onDetailRequested);
    on<ClockOrderStarted>(_onOrderStarted);
    on<ClockPaymentSubmitted>(_onPaymentSubmitted);
    on<ClockMyOrdersLoaded>(_onMyOrdersLoaded);
    on<ClocksOrderReset>(_onOrderReset);
  }

  Future<void> _onListLoaded(
    ClocksListLoaded event,
    Emitter<ClocksState> emit,
  ) async {
    emit(state.copyWith(
      listStatus: ClocksListStatus.loading,
      search: event.search,
      clearError: true,
    ));
    final result = await _repository.getClocks(
      search: event.search.isEmpty ? null : event.search,
      inStockOnly: event.inStockOnly,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        listStatus: ClocksListStatus.error,
        errorMessage: failure.message,
      )),
      (clocks) => emit(state.copyWith(
        listStatus: ClocksListStatus.loaded,
        clocks: clocks,
      )),
    );
  }

  Future<void> _onSearchChanged(
    ClocksSearchChanged event,
    Emitter<ClocksState> emit,
  ) async {
    add(ClocksListLoaded(search: event.query));
  }

  Future<void> _onDetailRequested(
    ClockDetailRequested event,
    Emitter<ClocksState> emit,
  ) async {
    emit(state.copyWith(
      detailStatus: ClockDetailStatus.loading,
      clearSelectedClock: true,
      clearError: true,
    ));
    final result = await _repository.getClockDetail(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        detailStatus: ClockDetailStatus.error,
        errorMessage: failure.message,
      )),
      (clock) => emit(state.copyWith(
        detailStatus: ClockDetailStatus.loaded,
        selectedClock: clock,
      )),
    );
  }

  Future<void> _onOrderStarted(
    ClockOrderStarted event,
    Emitter<ClocksState> emit,
  ) async {
    emit(state.copyWith(
      orderStatus: ClockOrderStatus.placing,
      clearCurrentOrder: true,
      clearError: true,
    ));
    final result = await _repository.placeOrder(
      clockId: event.clockId,
      quantity: event.quantity,
      note: event.note,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        orderStatus: ClockOrderStatus.error,
        errorMessage: failure.message,
      )),
      (order) => emit(state.copyWith(
        orderStatus: ClockOrderStatus.placed,
        currentOrder: order,
      )),
    );
  }

  Future<void> _onPaymentSubmitted(
    ClockPaymentSubmitted event,
    Emitter<ClocksState> emit,
  ) async {
    emit(state.copyWith(
      orderStatus: ClockOrderStatus.paying,
      clearError: true,
    ));
    final result = await _repository.submitPaymentProof(
      orderId: event.orderId,
      proofUrl: event.proofUrl,
      note: event.note,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        orderStatus: ClockOrderStatus.error,
        errorMessage: failure.message,
      )),
      (order) => emit(state.copyWith(
        orderStatus: ClockOrderStatus.paid,
        currentOrder: order,
      )),
    );
  }

  Future<void> _onMyOrdersLoaded(
    ClockMyOrdersLoaded event,
    Emitter<ClocksState> emit,
  ) async {
    emit(state.copyWith(myOrdersLoading: true));
    final result = await _repository.getMyOrders();
    result.fold(
      (_) => emit(state.copyWith(myOrdersLoading: false)),
      (orders) => emit(state.copyWith(
        myOrders: orders,
        myOrdersLoading: false,
      )),
    );
  }

  void _onOrderReset(ClocksOrderReset event, Emitter<ClocksState> emit) {
    emit(state.copyWith(
      orderStatus: ClockOrderStatus.idle,
      clearCurrentOrder: true,
      clearError: true,
    ));
  }
}
