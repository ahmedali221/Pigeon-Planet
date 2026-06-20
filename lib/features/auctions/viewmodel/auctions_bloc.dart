import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../model/asset_rating_model.dart';
import '../model/auction_comment_model.dart';
import '../model/auction_create_payload.dart';
import '../model/auction_model.dart';
import '../model/auctions_repository.dart';
import '../model/bid_model.dart';
import '../model/bird_summary_model.dart';

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
    on<AuctionSellerBirdsRequested>(_onSellerBirdsRequested);
    on<AuctionAvailableBirdIdsRequested>(_onAvailableBirdIdsRequested);
    on<AuctionCreateRequested>(_onCreateRequested);
    on<AuctionItemDetailRequested>(_onItemDetailRequested);
    on<AuctionCancelRequested>(_onCancelRequested);
    on<AuctionUpdateRequested>(_onUpdateRequested);
    on<AuctionBuyNowRequested>(_onBuyNowRequested);
    on<AuctionMyBidsLoadRequested>(_onMyBidsLoad);
    on<AuctionChatLoadRequested>(_onChatLoadRequested);
    on<AuctionCommentPosted>(_onCommentPosted);
    on<AuctionChatToggleRequested>(_onChatToggleRequested);
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
    List<AssetRatingModel> reviews = [];

    if (auction.items.isNotEmpty) {
      final firstItem = auction.items.first;
      final bidsResult = await _repository.getBidsForItem(firstItem.id);
      bids = bidsResult.fold((_) => [], (b) => b);

      // Fetch ratings for every bird across all items in parallel, then merge.
      final birdIds = auction.items
          .map((item) => item.bird.id)
          .toSet(); // deduplicate (e.g. PAIR shares a single item)
      final ratingResults = await Future.wait(
        birdIds.map((id) => _repository.getAssetRatings(id)),
      );
      reviews = ratingResults
          .expand((result) => result.fold((_) => <AssetRatingModel>[], (r) => r))
          .toList();
    }

    emit(state.copyWith(
      status: AuctionsStatus.detail,
      selectedAuction: auction,
      bids: bids,
      reviews: reviews,
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
        // Refresh auction detail (updates item prices in the overview list).
        if (state.selectedAuction != null) {
          await _onDetailRequested(
            AuctionDetailRequested(state.selectedAuction!.id),
            emit,
          );
        }
        // Refresh per-item bids so the item detail page reflects the new bid.
        final item = state.selectedAuction?.items
            .firstWhere((i) => i.id == event.itemId, orElse: () => state.selectedAuction!.items.first);
        if (item != null) {
          await _onItemDetailRequested(
            AuctionItemDetailRequested(itemId: event.itemId, birdId: item.bird.id),
            emit,
          );
        }
      },
    );
  }

  Future<void> _onItemDetailRequested(
    AuctionItemDetailRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isItemLoading: true));
    final bidsResult = await _repository.getBidsForItem(event.itemId);
    final reviewsResult = await _repository.getAssetRatings(event.birdId);
    emit(state.copyWith(
      isItemLoading: false,
      itemBids: bidsResult.fold((_) => [], (b) => b),
      itemReviews: reviewsResult.fold((_) => [], (r) => r),
    ));
  }

  Future<void> _onSellerBirdsRequested(
    AuctionSellerBirdsRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(sellerBirdsLoading: true, clearCreateError: true));
    final result = await _repository.getSellerBirds(
      mineOnly: event.mineOnly,
      availableForAuction: event.availableForAuction,
    );
    result.fold(
      (f) => emit(state.copyWith(sellerBirdsLoading: false, createError: f.message)),
      (birds) => emit(state.copyWith(sellerBirdsLoading: false, sellerBirds: birds)),
    );
  }

  Future<void> _onAvailableBirdIdsRequested(
    AuctionAvailableBirdIdsRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    final result = await _repository.getSellerBirds(
      mineOnly: true,
      availableForAuction: true,
    );
    result.fold(
      (_) {},
      (birds) => emit(state.copyWith(
        availableForAuctionBirdIds: birds.map((b) => b.id).toSet(),
      )),
    );
  }

  Future<void> _onCreateRequested(
    AuctionCreateRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, clearCreateError: true));
    final result = await _repository.createAuction(event.payload);
    result.fold(
      (f) => emit(state.copyWith(isCreating: false, createError: f.message)),
      (auction) => emit(state.copyWith(
        isCreating: false,
        createdAuction: auction,
      )),
    );
  }

  Future<void> _onCancelRequested(
    AuctionCancelRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isCancelling: true, clearCancelError: true));
    final result = await _repository.cancelAuction(event.auctionId);
    await result.fold(
      (f) async => emit(state.copyWith(isCancelling: false, cancelError: f.message)),
      (_) async {
        emit(state.copyWith(isCancelling: false));
        add(const AuctionsFilterChanged('my_auctions'));
      },
    );
  }

  Future<void> _onUpdateRequested(
    AuctionUpdateRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearUpdateError: true));
    final result = await _repository.updateAuction(
      event.auctionId,
      title: event.title,
      description: event.description,
      tags: event.tags,
      chatEnabled: event.chatEnabled,
    );
    result.fold(
      (f) => emit(state.copyWith(isUpdating: false, updateError: f.message)),
      (auction) {
        final updated = state.auctions.map((a) => a.id == auction.id ? auction : a).toList();
        emit(state.copyWith(
          isUpdating: false,
          selectedAuction: auction,
          auctions: updated,
        ));
      },
    );
  }

  Future<void> _onBuyNowRequested(
    AuctionBuyNowRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isBuyingNow: true, clearBuyNowError: true));
    final result = await _repository.buyNow(event.itemId);
    await result.fold(
      (f) async => emit(state.copyWith(isBuyingNow: false, buyNowError: f.message)),
      (_) async {
        emit(state.copyWith(isBuyingNow: false));
        if (state.selectedAuction != null) {
          await _onDetailRequested(
            AuctionDetailRequested(state.selectedAuction!.id),
            emit,
          );
        }
      },
    );
  }

  Future<void> _onMyBidsLoad(
    AuctionMyBidsLoadRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(myBidsLoading: true));
    final result = await _repository.getMyBids();
    result.fold(
      (f) => emit(state.copyWith(myBidsLoading: false)),
      (bids) => emit(state.copyWith(myBidsLoading: false, myBids: bids)),
    );
  }

  Future<void> _onChatLoadRequested(
    AuctionChatLoadRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isChatLoading: true, clearChatError: true));
    final result = await _repository.getAuctionComments(event.auctionId);
    result.fold(
      (f) => emit(state.copyWith(isChatLoading: false, chatError: f.message)),
      (comments) => emit(state.copyWith(isChatLoading: false, chatComments: comments)),
    );
  }

  Future<void> _onCommentPosted(
    AuctionCommentPosted event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isSendingComment: true, clearChatError: true));
    final result = await _repository.postAuctionComment(
      event.auctionId,
      event.body,
      event.isAnnouncement,
    );
    result.fold(
      (f) => emit(state.copyWith(isSendingComment: false, chatError: f.message)),
      (comment) => emit(state.copyWith(
        isSendingComment: false,
        chatComments: [...state.chatComments, comment],
      )),
    );
  }

  Future<void> _onChatToggleRequested(
    AuctionChatToggleRequested event,
    Emitter<AuctionsState> emit,
  ) async {
    emit(state.copyWith(isUpdating: true, clearUpdateError: true));
    final result = await _repository.updateAuction(
      event.auctionId,
      chatEnabled: event.chatEnabled,
    );
    result.fold(
      (f) => emit(state.copyWith(isUpdating: false, updateError: f.message)),
      (auction) {
        final updated = state.auctions.map((a) => a.id == auction.id ? auction : a).toList();
        emit(state.copyWith(isUpdating: false, selectedAuction: auction, auctions: updated));
      },
    );
  }
}
