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
