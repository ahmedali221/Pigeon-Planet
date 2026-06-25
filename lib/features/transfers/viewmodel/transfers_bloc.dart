import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/model/seller_model.dart';
import '../model/ownership_transfer_model.dart';
import '../model/transfers_repository.dart';

part 'transfers_event.dart';
part 'transfers_state.dart';

class TransfersBloc extends Bloc<TransfersEvent, TransfersState> {
  final TransfersRepository _repository;

  TransfersBloc({required TransfersRepository repository})
      : _repository = repository,
        super(const TransfersState()) {
    on<TransfersLoadRequested>(_onLoad);
    on<TransferCreateRequested>(_onCreate);
    on<TransferSellerSearchRequested>(_onSearchSellers);
  }

  Future<void> _onLoad(
    TransfersLoadRequested event,
    Emitter<TransfersState> emit,
  ) async {
    emit(state.copyWith(status: TransfersStatus.loading, clearError: true));
    final result = await _repository.getTransfers(assetId: event.assetId);
    result.fold(
      (f) => emit(state.copyWith(
        status: TransfersStatus.error,
        errorMessage: f.message,
      )),
      (transfers) => emit(state.copyWith(
        status: TransfersStatus.loaded,
        transfers: transfers,
      )),
    );
  }

  Future<void> _onSearchSellers(
    TransferSellerSearchRequested event,
    Emitter<TransfersState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(sellerSearchResults: [], isSearching: false));
      return;
    }
    emit(state.copyWith(isSearching: true));
    final result = await _repository.searchSellers(event.query.trim());
    result.fold(
      (_) => emit(state.copyWith(isSearching: false, sellerSearchResults: [])),
      (sellers) => emit(state.copyWith(
        isSearching: false,
        sellerSearchResults: sellers,
      )),
    );
  }

  Future<void> _onCreate(
    TransferCreateRequested event,
    Emitter<TransfersState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearCreateError: true, created: false));
    final result = await _repository.createTransfer(
      assetId: event.assetId,
      toProfileId: event.toProfileId,
      note: event.note,
    );
    result.fold(
      (f) => emit(state.copyWith(isCreating: false, createError: f.message)),
      (transfer) => emit(state.copyWith(
        isCreating: false,
        created: true,
        transfers: [transfer, ...state.transfers],
      )),
    );
  }
}
