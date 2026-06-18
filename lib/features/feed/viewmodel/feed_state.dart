import 'package:equatable/equatable.dart';

import '../../home/model/seller_model.dart';
import '../model/feed_auction_item_model.dart';
import '../model/seller_block_model.dart';
import '../model/seller_follow_model.dart';

enum FeedStatus { initial, loading, loaded, error }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<SellerFollowModel> following;
  final List<SellerModel> suggestions;
  final List<SellerBlockModel> blocks;
  final List<FeedAuctionItemModel> auctionFeed;
  final String? auctionCursor;
  final bool auctionHasMore;
  final bool auctionLoadingMore;
  final Set<int> followedSellerIds;
  final Set<int> blockedProfileIds;
  final String? errorMessage;
  final String? actionError;

  const FeedState({
    this.status = FeedStatus.initial,
    this.following = const [],
    this.suggestions = const [],
    this.blocks = const [],
    this.auctionFeed = const [],
    this.auctionCursor,
    this.auctionHasMore = false,
    this.auctionLoadingMore = false,
    this.followedSellerIds = const {},
    this.blockedProfileIds = const {},
    this.errorMessage,
    this.actionError,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<SellerFollowModel>? following,
    List<SellerModel>? suggestions,
    List<SellerBlockModel>? blocks,
    List<FeedAuctionItemModel>? auctionFeed,
    String? auctionCursor,
    bool? auctionHasMore,
    bool? auctionLoadingMore,
    Set<int>? followedSellerIds,
    Set<int>? blockedProfileIds,
    String? errorMessage,
    String? actionError,
    bool clearAuctionCursor = false,
    bool clearActionError = false,
  }) =>
      FeedState(
        status: status ?? this.status,
        following: following ?? this.following,
        suggestions: suggestions ?? this.suggestions,
        blocks: blocks ?? this.blocks,
        auctionFeed: auctionFeed ?? this.auctionFeed,
        auctionCursor: clearAuctionCursor ? null : (auctionCursor ?? this.auctionCursor),
        auctionHasMore: auctionHasMore ?? this.auctionHasMore,
        auctionLoadingMore: auctionLoadingMore ?? this.auctionLoadingMore,
        followedSellerIds: followedSellerIds ?? this.followedSellerIds,
        blockedProfileIds: blockedProfileIds ?? this.blockedProfileIds,
        errorMessage: errorMessage ?? this.errorMessage,
        actionError: clearActionError ? null : (actionError ?? this.actionError),
      );

  bool isFollowing(int sellerId) => followedSellerIds.contains(sellerId);
  bool isBlocked(int profileId) => blockedProfileIds.contains(profileId);

  @override
  List<Object?> get props => [
        status,
        following,
        suggestions,
        blocks,
        auctionFeed,
        auctionCursor,
        auctionHasMore,
        auctionLoadingMore,
        followedSellerIds,
        blockedProfileIds,
        errorMessage,
        actionError,
      ];
}
