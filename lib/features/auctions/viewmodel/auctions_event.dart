part of 'auctions_bloc.dart';

abstract class AuctionsEvent extends Equatable {
  const AuctionsEvent();

  @override
  List<Object?> get props => [];
}

class AuctionsStarted extends AuctionsEvent {
  const AuctionsStarted();
}

class AuctionsRefreshRequested extends AuctionsEvent {
  const AuctionsRefreshRequested();
}

class AuctionsFilterChanged extends AuctionsEvent {
  // 'all' | 'ending_soon' | 'my_auctions'
  final String filter;
  const AuctionsFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class AuctionDetailRequested extends AuctionsEvent {
  final int auctionId;
  const AuctionDetailRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class AuctionBidPlaced extends AuctionsEvent {
  final int itemId;
  final double amount;
  const AuctionBidPlaced({required this.itemId, required this.amount});

  @override
  List<Object?> get props => [itemId, amount];
}

class AuctionSellerBirdsRequested extends AuctionsEvent {
  final bool mineOnly;
  final bool availableForAuction;
  const AuctionSellerBirdsRequested({
    this.mineOnly = false,
    this.availableForAuction = false,
  });

  @override
  List<Object?> get props => [mineOnly, availableForAuction];
}

class AuctionAvailableBirdIdsRequested extends AuctionsEvent {
  const AuctionAvailableBirdIdsRequested();
}

class AuctionCreateRequested extends AuctionsEvent {
  final AuctionCreatePayload payload;
  const AuctionCreateRequested(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AuctionItemDetailRequested extends AuctionsEvent {
  final int itemId;
  final int birdId;
  const AuctionItemDetailRequested({required this.itemId, required this.birdId});

  @override
  List<Object?> get props => [itemId, birdId];
}
