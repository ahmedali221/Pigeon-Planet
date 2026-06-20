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

class AuctionCancelRequested extends AuctionsEvent {
  final int auctionId;
  const AuctionCancelRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class AuctionUpdateRequested extends AuctionsEvent {
  final int auctionId;
  final String? title;
  final String? description;
  final String? tags;
  final bool? chatEnabled;
  const AuctionUpdateRequested({
    required this.auctionId,
    this.title,
    this.description,
    this.tags,
    this.chatEnabled,
  });

  @override
  List<Object?> get props => [auctionId, title, description, tags, chatEnabled];
}

class AuctionChatLoadRequested extends AuctionsEvent {
  final int auctionId;
  const AuctionChatLoadRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class AuctionCommentPosted extends AuctionsEvent {
  final int auctionId;
  final String body;
  final bool isAnnouncement;
  const AuctionCommentPosted({
    required this.auctionId,
    required this.body,
    this.isAnnouncement = false,
  });

  @override
  List<Object?> get props => [auctionId, body, isAnnouncement];
}

class AuctionChatToggleRequested extends AuctionsEvent {
  final int auctionId;
  final bool chatEnabled;
  const AuctionChatToggleRequested({required this.auctionId, required this.chatEnabled});

  @override
  List<Object?> get props => [auctionId, chatEnabled];
}

class AuctionBuyNowRequested extends AuctionsEvent {
  final int itemId;
  const AuctionBuyNowRequested(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class AuctionMyBidsLoadRequested extends AuctionsEvent {
  const AuctionMyBidsLoadRequested();
}
