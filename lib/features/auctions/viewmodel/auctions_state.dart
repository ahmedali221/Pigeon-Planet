part of 'auctions_bloc.dart';

enum AuctionsStatus { initial, loading, loaded, detail, error }

class AuctionsState extends Equatable {
  final AuctionsStatus status;
  final List<AuctionModel> auctions;
  final AuctionModel? selectedAuction;
  final List<BidModel> bids;
  final List<AssetRatingModel> reviews;
  // Per selected item (loaded when user opens an item detail)
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

  const AuctionsState({
    this.status = AuctionsStatus.initial,
    this.auctions = const [],
    this.selectedAuction,
    this.bids = const [],
    this.reviews = const [],
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
  });

  AuctionsState copyWith({
    AuctionsStatus? status,
    List<AuctionModel>? auctions,
    AuctionModel? selectedAuction,
    bool clearSelectedAuction = false,
    List<BidModel>? bids,
    List<AssetRatingModel>? reviews,
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
  }) =>
      AuctionsState(
        status: status ?? this.status,
        auctions: auctions ?? this.auctions,
        selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
        bids: bids ?? this.bids,
        reviews: reviews ?? this.reviews,
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
      );

  @override
  List<Object?> get props => [
        status,
        auctions,
        selectedAuction?.id,
        bids,
        reviews,
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
      ];
}
