import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../model/auction_model.dart';
import '../model/auctions_repository.dart';
import '../model/bid_model.dart';

part 'auctions_event.dart';
part 'auctions_state.dart';

class AuctionsBloc extends Bloc<AuctionsEvent, AuctionsState> {
  final AuctionsRepository _repository;

  AuctionsBloc({required AuctionsRepository repository})
      : _repository = repository,
        super(const AuctionsState()) {
    on<AuctionsStarted>(_onStarted);
    on<AuctionsRefreshRequested>(_onStarted);
    on<AuctionsFilterChanged>(_onFilterChanged);
    on<AuctionDetailRequested>(_onDetailRequested);
    on<AuctionBidPlaced>(_onBidPlaced);
  }

  Future<void> _onStarted(
    AuctionsEvent event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(status: AuctionsStatus.loading, clearError: true, clearSelectedAuction: true));
    final result = await _repository.getAuctions();
    result.fold(
      (f) => emit(state.copyWith(
          status: AuctionsStatus.error, errorMessage: f.message)),
      (list) => emit(state.copyWith(
          status: AuctionsStatus.loaded,
          auctions: list,
          activeFilter: 'all')),
    );
  }

  Future<void> _onFilterChanged(
    AuctionsFilterChanged event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(
        status: AuctionsStatus.loading, activeFilter: event.filter, clearError: true));

    late final Either<Failure, List<AuctionModel>> result;
    switch (event.filter) {
      case 'ending_soon':
        result = await _repository.getEndingSoon();
        break;
      case 'my_auctions':
        result = await _repository.getMyAuctions();
        break;
      default:
        result = await _repository.getAuctions();
    }

    result.fold(
      (f) => emit(state.copyWith(
          status: AuctionsStatus.error, errorMessage: f.message)),
      (list) => emit(state.copyWith(
          status: AuctionsStatus.loaded, auctions: list)),
    );
  }

  Future<void> _onDetailRequested(
    AuctionDetailRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(status: AuctionsStatus.loading));
    final result = await _repository.getAuctionDetail(event.auctionId);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => null)!;
      emit(state.copyWith(status: AuctionsStatus.error, errorMessage: failure.message));
      return;
    }

    final auction = result.getOrElse(() => throw StateError('unreachable'));
    List<BidModel> bids = [];
    if (auction.items.isNotEmpty) {
      final bidsResult = await _repository.getBidsForItem(auction.items.first.id);
      bids = bidsResult.fold((_) => [], (b) => b);
    }
    emit(state.copyWith(
      status: AuctionsStatus.detail,
      selectedAuction: auction,
      bids: bids,
    ));
  }

  Future<void> _onBidPlaced(
    AuctionBidPlaced event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isBidding: true));
    final result = await _repository.placeBid(event.itemId, event.amount);
    await result.fold(
      (f) async => emit(state.copyWith(isBidding: false, errorMessage: f.message)),
      (_) async {
        emit(state.copyWith(isBidding: false));
        if (state.selectedAuction != null) {
          await _onDetailRequested(
            AuctionDetailRequested(state.selectedAuction!.id),
            emit,
          );
        }
      },
    );
  }
}
