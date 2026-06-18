import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/feed_repository.dart';
import 'feed_event.dart';
import 'feed_state.dart';

export 'feed_event.dart';
export 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _repository;

  FeedBloc({required FeedRepository repository})
      : _repository = repository,
        super(const FeedState()) {
    on<FeedStarted>(_onStarted);
    on<FeedAuctionNextPageRequested>(_onNextPage);
    on<FeedFollowRequested>(_onFollow);
    on<FeedUnfollowRequested>(_onUnfollow);
    on<FeedBlockRequested>(_onBlock);
    on<FeedUnblockRequested>(_onUnblock);
    on<FeedFollowingRefreshed>(_onFollowingRefreshed);
    on<FeedSuggestionsRefreshed>(_onSuggestionsRefreshed);
  }

  Future<void> _onStarted(
    FeedStarted event,
    Emitter<FeedState> emit,
  ) async {
    if (state.status == FeedStatus.loaded) return;
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));

    final suggestResult = await _repository.getSuggestions();
    final feedResult = await _repository.getAuctionFeed();
    final followingResult = await _repository.getFollowing();

    final suggestions = suggestResult.getOrElse(() => []);
    final following = followingResult.getOrElse(() => []);
    final followedIds = following.map((f) => f.seller.id).toSet();

    feedResult.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.error,
        errorMessage: failure.message,
        suggestions: suggestions,
        following: following,
        followedSellerIds: followedIds,
      )),
      (result) => emit(state.copyWith(
        status: FeedStatus.loaded,
        auctionFeed: result.items,
        auctionCursor: result.nextCursor,
        auctionHasMore: result.nextCursor != null,
        suggestions: suggestions,
        following: following,
        followedSellerIds: followedIds,
      )),
    );
  }

  Future<void> _onNextPage(
    FeedAuctionNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.auctionLoadingMore || !state.auctionHasMore) return;
    emit(state.copyWith(auctionLoadingMore: true));

    final result = await _repository.getAuctionFeed(cursor: state.auctionCursor);
    result.fold(
      (_) => emit(state.copyWith(auctionLoadingMore: false)),
      (r) => emit(state.copyWith(
        auctionFeed: [...state.auctionFeed, ...r.items],
        auctionCursor: r.nextCursor,
        auctionHasMore: r.nextCursor != null,
        auctionLoadingMore: false,
      )),
    );
  }

  Future<void> _onFollow(
    FeedFollowRequested event,
    Emitter<FeedState> emit,
  ) async {
    final ids = Set<int>.from(state.followedSellerIds)..add(event.sellerId);
    emit(state.copyWith(followedSellerIds: ids, clearActionError: true));

    final result = await _repository.followSeller(event.sellerId);
    result.fold(
      (failure) {
        final revert = Set<int>.from(state.followedSellerIds)
          ..remove(event.sellerId);
        emit(state.copyWith(
          followedSellerIds: revert,
          actionError: failure.message,
        ));
      },
      (_) {
        // optimistic update already applied — also refresh following list
        add(const FeedFollowingRefreshed());
      },
    );
  }

  Future<void> _onUnfollow(
    FeedUnfollowRequested event,
    Emitter<FeedState> emit,
  ) async {
    final ids = Set<int>.from(state.followedSellerIds)..remove(event.sellerId);
    emit(state.copyWith(followedSellerIds: ids, clearActionError: true));

    final result = await _repository.unfollowSeller(event.sellerId);
    result.fold(
      (failure) {
        final revert = Set<int>.from(state.followedSellerIds)
          ..add(event.sellerId);
        emit(state.copyWith(
          followedSellerIds: revert,
          actionError: failure.message,
        ));
      },
      (_) => add(const FeedFollowingRefreshed()),
    );
  }

  Future<void> _onBlock(
    FeedBlockRequested event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _repository.blockProfile(event.profileId);
    result.fold(
      (failure) => emit(state.copyWith(actionError: failure.message)),
      (_) {
        final ids = Set<int>.from(state.blockedProfileIds)..add(event.profileId);
        final followIds = Set<int>.from(state.followedSellerIds)
          ..remove(event.profileId);
        emit(state.copyWith(
          blockedProfileIds: ids,
          followedSellerIds: followIds,
          clearActionError: true,
        ));
      },
    );
  }

  Future<void> _onUnblock(
    FeedUnblockRequested event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _repository.unblockProfile(event.profileId);
    result.fold(
      (failure) => emit(state.copyWith(actionError: failure.message)),
      (_) {
        final ids = Set<int>.from(state.blockedProfileIds)
          ..remove(event.profileId);
        emit(state.copyWith(
          blockedProfileIds: ids,
          clearActionError: true,
        ));
      },
    );
  }

  Future<void> _onFollowingRefreshed(
    FeedFollowingRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _repository.getFollowing();
    result.fold(
      (_) {},
      (following) {
        final ids = following.map((f) => f.seller.id).toSet();
        emit(state.copyWith(
          following: following,
          followedSellerIds: ids,
        ));
      },
    );
  }

  Future<void> _onSuggestionsRefreshed(
    FeedSuggestionsRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _repository.getSuggestions();
    result.fold(
      (_) {},
      (suggestions) => emit(state.copyWith(suggestions: suggestions)),
    );
  }
}
