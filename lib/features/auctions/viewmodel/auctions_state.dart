part of 'auctions_bloc.dart';

enum AuctionsStatus { initial, loading, loaded, detail, error }

class AuctionsState extends Equatable {
  final AuctionsStatus status;
  final List<AuctionModel> auctions;
  final AuctionModel? selectedAuction;
  final List<BidModel> bids;
  final String activeFilter;
  final String? errorMessage;
  final bool isBidding;

  const AuctionsState({
    this.status = AuctionsStatus.initial,
    this.auctions = const [],
    this.selectedAuction,
    this.bids = const [],
    this.activeFilter = 'all',
    this.errorMessage,
    this.isBidding = false,
  });

  AuctionsState copyWith({
    AuctionsStatus? status,
    List<AuctionModel>? auctions,
    AuctionModel? selectedAuction,
    bool clearSelectedAuction = false,
    List<BidModel>? bids,
    String? activeFilter,
    String? errorMessage,
    bool clearError = false,
    bool? isBidding,
  }) =>
      AuctionsState(
        status: status ?? this.status,
        auctions: auctions ?? this.auctions,
        selectedAuction: clearSelectedAuction ? null : (selectedAuction ?? this.selectedAuction),
        bids: bids ?? this.bids,
        activeFilter: activeFilter ?? this.activeFilter,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        isBidding: isBidding ?? this.isBidding,
      );

  @override
  List<Object?> get props => [
        status,
        auctions,
        selectedAuction?.id,
        bids,
        activeFilter,
        errorMessage,
        isBidding,
      ];
}
