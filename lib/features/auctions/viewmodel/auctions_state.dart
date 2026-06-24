part of 'auctions_bloc.dart';

enum AuctionsStatus { initial, loading, loaded, detail, error }

class AuctionsState extends Equatable {
  final AuctionsStatus status;
  final List<AuctionModel> auctions;
  final bool auctionsHasMore;
  final int auctionsCurrentPage;
  final bool auctionsLoadingMore;
  final AuctionModel? selectedAuction;
  final List<BidModel> bids;
  final List<AssetRatingModel> reviews;
  // Per selected item (loaded when user opens an item detail)
  final AuctionItemModel? selectedItemDetail;
  final List<BidModel> itemBids;
  final List<AssetRatingModel> itemReviews;
  final bool isItemLoading;
  final String activeFilter;
  final String? errorMessage;
  final bool isBidding;
  final List<BirdSummaryModel> sellerBirds;
  final bool sellerBirdsLoading;
  final bool isCreating;
  final String? createError;
  final AuctionModel? createdAuction;
  // null = not yet fetched; empty set = all birds are in auctions
  final Set<int>? availableForAuctionBirdIds;
  final bool isCancelling;
  final String? cancelError;
  final bool isBuyingNow;
  final String? buyNowError;
  final bool isUpdating;
  final String? updateError;
  final List<BidModel> myBids;
  final bool myBidsLoading;
  final bool myBidsLoadingMore;
  final bool myBidsHasMore;
  final int myBidsCurrentPage;

  const AuctionsState({
    this.status = AuctionsStatus.initial,
    this.auctions = const [],
    this.auctionsHasMore = false,
    this.auctionsCurrentPage = 1,
    this.auctionsLoadingMore = false,
    this.selectedAuction,
    this.bids = const [],
    this.reviews = const [],
    this.selectedItemDetail,
    this.itemBids = const [],
    this.itemReviews = const [],
    this.isItemLoading = false,
    this.activeFilter = 'all',
    this.errorMessage,
    this.isBidding = false,
    this.sellerBirds = const [],
    this.sellerBirdsLoading = false,
    this.isCreating = false,
    this.createError,
    this.createdAuction,
    this.availableForAuctionBirdIds,
    this.isCancelling = false,
    this.cancelError,
    this.isBuyingNow = false,
    this.buyNowError,
    this.isUpdating = false,
    this.updateError,
    this.myBids = const [],
    this.myBidsLoading = false,
    this.myBidsLoadingMore = false,
    this.myBidsHasMore = false,
    this.myBidsCurrentPage = 1,
  });

  AuctionsState copyWith({
    AuctionsStatus? status,
    List<AuctionModel>? auctions,
    bool? auctionsHasMore,
    int? auctionsCurrentPage,
    bool? auctionsLoadingMore,
    AuctionModel? selectedAuction,
    bool clearSelectedAuction = false,
    List<BidModel>? bids,
    List<AssetRatingModel>? reviews,
    AuctionItemModel? selectedItemDetail,
    bool clearSelectedItemDetail = false,
    List<BidModel>? itemBids,
    List<AssetRatingModel>? itemReviews,
    bool? isItemLoading,
    String? activeFilter,
    String? errorMessage,
    bool clearError = false,
    bool? isBidding,
    List<BirdSummaryModel>? sellerBirds,
    bool? sellerBirdsLoading,
    bool? isCreating,
    String? createError,
    bool clearCreateError = false,
    AuctionModel? createdAuction,
    bool clearCreatedAuction = false,
    Set<int>? availableForAuctionBirdIds,
    bool clearAvailableBirdIds = false,
    bool? isCancelling,
    String? cancelError,
    bool clearCancelError = false,
    bool? isBuyingNow,
    String? buyNowError,
    bool clearBuyNowError = false,
    bool? isUpdating,
    String? updateError,
    bool clearUpdateError = false,
    List<BidModel>? myBids,
    bool? myBidsLoading,
    bool? myBidsLoadingMore,
    bool? myBidsHasMore,
    int? myBidsCurrentPage,
  }) =>
      AuctionsState(
        status: status ?? this.status,
        auctions: auctions ?? this.auctions,
        auctionsHasMore: auctionsHasMore ?? this.auctionsHasMore,
        auctionsCurrentPage: auctionsCurrentPage ?? this.auctionsCurrentPage,
        auctionsLoadingMore: auctionsLoadingMore ?? this.auctionsLoadingMore,
        selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
        bids: bids ?? this.bids,
        reviews: reviews ?? this.reviews,
        selectedItemDetail: clearSelectedItemDetail
            ? null
            : (selectedItemDetail ?? this.selectedItemDetail),
        itemBids: itemBids ?? this.itemBids,
        itemReviews: itemReviews ?? this.itemReviews,
        isItemLoading: isItemLoading ?? this.isItemLoading,
        activeFilter: activeFilter ?? this.activeFilter,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isBidding: isBidding ?? this.isBidding,
        sellerBirds: sellerBirds ?? this.sellerBirds,
        sellerBirdsLoading: sellerBirdsLoading ?? this.sellerBirdsLoading,
        isCreating: isCreating ?? this.isCreating,
        createError: clearCreateError ? null : (createError ?? this.createError),
        createdAuction: clearCreatedAuction ? null : (createdAuction ?? this.createdAuction),
        availableForAuctionBirdIds: clearAvailableBirdIds
            ? null
            : (availableForAuctionBirdIds ?? this.availableForAuctionBirdIds),
        isCancelling: isCancelling ?? this.isCancelling,
        cancelError: clearCancelError ? null : (cancelError ?? this.cancelError),
        isBuyingNow: isBuyingNow ?? this.isBuyingNow,
        buyNowError: clearBuyNowError ? null : (buyNowError ?? this.buyNowError),
        isUpdating: isUpdating ?? this.isUpdating,
        updateError: clearUpdateError ? null : (updateError ?? this.updateError),
        myBids: myBids ?? this.myBids,
        myBidsLoading: myBidsLoading ?? this.myBidsLoading,
        myBidsLoadingMore: myBidsLoadingMore ?? this.myBidsLoadingMore,
        myBidsHasMore: myBidsHasMore ?? this.myBidsHasMore,
        myBidsCurrentPage: myBidsCurrentPage ?? this.myBidsCurrentPage,
      );

  @override
  List<Object?> get props => [
        status,
        auctions,
        auctionsHasMore,
        auctionsCurrentPage,
        auctionsLoadingMore,
        selectedAuction?.id,
        bids,
        reviews,
        selectedItemDetail,
        itemBids,
        itemReviews,
        isItemLoading,
        activeFilter,
        errorMessage,
        isBidding,
        sellerBirds,
        sellerBirdsLoading,
        isCreating,
        createError,
        createdAuction?.id,
        availableForAuctionBirdIds,
        isCancelling,
        cancelError,
        isBuyingNow,
        buyNowError,
        isUpdating,
        updateError,
        myBids,
        myBidsLoading,
        myBidsLoadingMore,
        myBidsHasMore,
        myBidsCurrentPage,
      ];
}
