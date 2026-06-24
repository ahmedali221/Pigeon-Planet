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
    on<FeedSellersListRequested>(_onSellersListRequested);
    on<FeedSellersListNextPageRequested>(_onSellersListNextPage);
    on<FeedPackageFollowRequested>(_onPackageFollow);
    on<FeedPackageUnfollowRequested>(_onPackageUnfollow);
    on<FeedPackageFollowingRefreshed>(_onPackageFollowingRefreshed);
  }

  Future<void> _onStarted(
    FeedStarted event,
    Emitter<FeedState> emit,
  ) async {
    if (state.status == FeedStatus.loaded) return;
    emit(state.copyWith(status: FeedStatus.loading, errorMessage: null));

    // Fire all requests concurrently — none blocks another.
    final feedFuture = _repository.getAuctionFeed();
    final suggestFuture = _repository.getSuggestions();
    final followingFuture = _repository.getFollowing();
    final pkgFollowingFuture = _repository.getFollowingPackages();
    final blocksFuture = _repository.getBlocks();

    // Emit cards the moment the auction feed arrives.
    final feedResult = await feedFuture;
    feedResult.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.error,
        errorMessage: failure.message,
      )),
      (result) => emit(state.copyWith(
        status: FeedStatus.loaded,
        auctionFeed: result.items,
        auctionCursor: result.nextCursor,
        auctionHasMore: result.nextCursor != null,
      )),
    );

    // Collect metadata (already in-flight) and patch state silently.
    final suggestions = (await suggestFuture).getOrElse(() => []);
    final following = (await followingFuture).getOrElse(() => []);
    final pkgFollowing = (await pkgFollowingFuture).getOrElse(() => []);
    final blocks = (await blocksFuture).getOrElse(() => []);

    emit(state.copyWith(
      suggestions: suggestions,
      following: following,
      followedSellerIds: following.map((f) => f.seller.id).toSet(),
      followingPackages: pkgFollowing,
      followedPackageIds: pkgFollowing.map((p) => p.packageId).toSet(),
      blocks: blocks,
      blockedProfileIds: blocks.map((b) => b.profileId).toSet(),
    ));
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

  Future<void> _onSellersListRequested(
    FeedSellersListRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.sellersStatus == SellersListStatus.loading) return;
    emit(state.copyWith(
      sellersStatus: SellersListStatus.loading,
      sellersList: [],
      sellersPage: 1,
    ));
    final result = await _repository.getSellersList(1);
    result.fold(
      (failure) => emit(state.copyWith(
        sellersStatus: SellersListStatus.error,
        actionError: failure.message,
      )),
      (data) => emit(state.copyWith(
        sellersStatus: SellersListStatus.loaded,
        sellersList: data.sellers,
        sellersPage: 1,
        sellersHasMore: data.hasMore,
      )),
    );
  }

  Future<void> _onSellersListNextPage(
    FeedSellersListNextPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    if (state.sellersStatus == SellersListStatus.loadingMore ||
        !state.sellersHasMore) {
      return;
    }
    emit(state.copyWith(sellersStatus: SellersListStatus.loadingMore));
    final nextPage = state.sellersPage + 1;
    final result = await _repository.getSellersList(nextPage);
    result.fold(
      (_) => emit(state.copyWith(sellersStatus: SellersListStatus.loaded)),
      (data) => emit(state.copyWith(
        sellersStatus: SellersListStatus.loaded,
        sellersList: [...state.sellersList, ...data.sellers],
        sellersPage: nextPage,
        sellersHasMore: data.hasMore,
      )),
    );
  }

  Future<void> _onPackageFollow(
    FeedPackageFollowRequested event,
    Emitter<FeedState> emit,
  ) async {
    final ids = Set<int>.from(state.followedPackageIds)..add(event.packageId);
    emit(state.copyWith(followedPackageIds: ids, clearActionError: true));

    final result = await _repository.followSellerPackage(event.packageId);
    result.fold(
      (failure) {
        final revert = Set<int>.from(state.followedPackageIds)
          ..remove(event.packageId);
        emit(state.copyWith(
          followedPackageIds: revert,
          actionError: failure.message,
        ));
      },
      (_) => add(const FeedPackageFollowingRefreshed()),
    );
  }

  Future<void> _onPackageUnfollow(
    FeedPackageUnfollowRequested event,
    Emitter<FeedState> emit,
  ) async {
    final ids = Set<int>.from(state.followedPackageIds)
      ..remove(event.packageId);
    emit(state.copyWith(followedPackageIds: ids, clearActionError: true));

    final result = await _repository.unfollowSellerPackage(event.packageId);
    result.fold(
      (failure) {
        final revert = Set<int>.from(state.followedPackageIds)
          ..add(event.packageId);
        emit(state.copyWith(
          followedPackageIds: revert,
          actionError: failure.message,
        ));
      },
      (_) => add(const FeedPackageFollowingRefreshed()),
    );
  }

  Future<void> _onPackageFollowingRefreshed(
    FeedPackageFollowingRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    final result = await _repository.getFollowingPackages();
    result.fold(
      (_) {},
      (packages) {
        final ids = packages.map((p) => p.packageId).toSet();
        emit(state.copyWith(
          followingPackages: packages,
          followedPackageIds: ids,
        ));
      },
    );
  }
}
