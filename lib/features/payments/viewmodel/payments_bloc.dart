import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/payment_request_model.dart';
import '../model/payments_repository.dart';

part 'payments_event.dart';
part 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentsRepository _repository;

  PaymentsBloc({required PaymentsRepository repository})
    : _repository = repository,
      super(const PaymentsState()) {
    on<PaymentsLoadRequested>(_onLoad);
    on<AuctionPaymentCreateRequested>(_onCreateAuction);
    on<MarketPaymentCreateRequested>(_onCreateMarket);
    on<PaymentBuyerNoteUpdateRequested>(_onUpdateNote);
    on<PaymentApproveRequested>(_onApprove);
    on<PaymentRejectRequested>(_onReject);
  }

  Future<void> _onLoad(
    PaymentsLoadRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    final result = await _repository.getPaymentRequests();
    result.fold(
      (f) => emit(
        state.copyWith(status: PaymentsStatus.error, errorMessage: f.message),
      ),
      (requests) => emit(
        state.copyWith(status: PaymentsStatus.loaded, requests: requests),
      ),
    );
  }

  Future<void> _onCreateAuction(
    AuctionPaymentCreateRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(
      PaymentsState(
        status: state.status,
        requests: state.requests,
        isCreating: true,
      ),
    );
    final existingResult = await _repository.getPaymentRequests();
    final existing = existingResult.fold(
      (_) => null,
      (requests) => _findActiveAuctionRequest(requests, event.auctionItemId),
    );
    if (existing != null) {
      // Attach new proof to the existing request before surfacing it.
      if (event.proofFile != null) {
        await _repository.updateBuyerNote(
          existing.id,
          event.buyerNote ?? existing.buyerNote ?? '',
          proofFile: event.proofFile,
        );
      }
      add(const PaymentsLoadRequested());
      emit(state.copyWith(isCreating: false, reusedExistingRequest: true));
      return;
    }

    final result = await _repository.createAuctionPaymentRequest(
      event.auctionItemId,
      buyerNote: event.buyerNote,
      proofFile: event.proofFile,
    );
    result.fold(
      (f) => emit(state.copyWith(isCreating: false, createError: f.message)),
      (_) {
        emit(state.copyWith(isCreating: false));
        add(const PaymentsLoadRequested());
      },
    );
  }

  Future<void> _onCreateMarket(
    MarketPaymentCreateRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(
      PaymentsState(
        status: state.status,
        requests: state.requests,
        isCreating: true,
      ),
    );
    final existingResult = await _repository.getPaymentRequests();
    final existing = existingResult.fold(
      (_) => null,
      (requests) => _findActiveMarketRequest(requests, event.orderItemId),
    );
    if (existing != null) {
      // Attach new proof to the existing request before surfacing it.
      if (event.proofFile != null) {
        await _repository.updateBuyerNote(
          existing.id,
          event.buyerNote ?? existing.buyerNote ?? '',
          proofFile: event.proofFile,
        );
      }
      add(const PaymentsLoadRequested());
      emit(state.copyWith(isCreating: false, reusedExistingRequest: true));
      return;
    }

    final result = await _repository.createMarketPaymentRequest(
      event.orderItemId,
      buyerNote: event.buyerNote,
      proofFile: event.proofFile,
    );
    result.fold(
      (f) => emit(state.copyWith(isCreating: false, createError: f.message)),
      (_) {
        emit(state.copyWith(isCreating: false));
        add(const PaymentsLoadRequested());
      },
    );
  }

  Future<void> _onUpdateNote(
    PaymentBuyerNoteUpdateRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(state.copyWith(isActing: true));
    final result = await _repository.updateBuyerNote(
      event.requestId,
      event.buyerNote,
      proofFile: event.proofFile,
    );
    result.fold(
      (f) => emit(state.copyWith(isActing: false, actionError: f.message)),
      (updated) => emit(
        state.copyWith(isActing: false, requests: _replaceRequest(updated)),
      ),
    );
  }

  Future<void> _onApprove(
    PaymentApproveRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(state.copyWith(isActing: true));
    final result = await _repository.approvePaymentRequest(event.requestId);
    result.fold(
      (f) => emit(state.copyWith(isActing: false, actionError: f.message)),
      (updated) => emit(
        state.copyWith(isActing: false, requests: _replaceRequest(updated)),
      ),
    );
  }

  Future<void> _onReject(
    PaymentRejectRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(state.copyWith(isActing: true));
    final result = await _repository.rejectPaymentRequest(
      event.requestId,
      sellerNote: event.sellerNote,
    );
    result.fold(
      (f) => emit(state.copyWith(isActing: false, actionError: f.message)),
      (updated) => emit(
        state.copyWith(isActing: false, requests: _replaceRequest(updated)),
      ),
    );
  }

  List<PaymentRequestModel> _replaceRequest(PaymentRequestModel updated) =>
      state.requests.map((r) => r.id == updated.id ? updated : r).toList();

  PaymentRequestModel? _findActiveAuctionRequest(
    List<PaymentRequestModel> requests,
    int auctionItemId,
  ) => _findActiveRequest(
    requests,
    (request) => request.auctionItemId == auctionItemId,
  );

  PaymentRequestModel? _findActiveMarketRequest(
    List<PaymentRequestModel> requests,
    int orderItemId,
  ) => _findActiveRequest(
    requests,
    (request) => request.orderItemId == orderItemId,
  );

  PaymentRequestModel? _findActiveRequest(
    List<PaymentRequestModel> requests,
    bool Function(PaymentRequestModel request) matchesSource,
  ) {
    for (final request in requests) {
      if (matchesSource(request) && (request.isPending || request.isRejected)) {
        return request;
      }
    }
    return null;
  }
}
