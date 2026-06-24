import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedAuctionNextPageRequested extends FeedEvent {
  const FeedAuctionNextPageRequested();
}

class FeedFollowRequested extends FeedEvent {
  final int sellerId;
  const FeedFollowRequested(this.sellerId);
  @override
  List<Object?> get props => [sellerId];
}

class FeedUnfollowRequested extends FeedEvent {
  final int sellerId;
  const FeedUnfollowRequested(this.sellerId);
  @override
  List<Object?> get props => [sellerId];
}

class FeedBlockRequested extends FeedEvent {
  final int profileId;
  const FeedBlockRequested(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class FeedUnblockRequested extends FeedEvent {
  final int profileId;
  const FeedUnblockRequested(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class FeedFollowingRefreshed extends FeedEvent {
  const FeedFollowingRefreshed();
}

class FeedSuggestionsRefreshed extends FeedEvent {
  const FeedSuggestionsRefreshed();
}

class FeedSellersListRequested extends FeedEvent {
  const FeedSellersListRequested();
}

class FeedSellersListNextPageRequested extends FeedEvent {
  const FeedSellersListNextPageRequested();
}

class FeedPackageFollowRequested extends FeedEvent {
  final int packageId;
  const FeedPackageFollowRequested(this.packageId);
  @override
  List<Object?> get props => [packageId];
}

class FeedPackageUnfollowRequested extends FeedEvent {
  final int packageId;
  const FeedPackageUnfollowRequested(this.packageId);
  @override
  List<Object?> get props => [packageId];
}

class FeedPackageFollowingRefreshed extends FeedEvent {
  const FeedPackageFollowingRefreshed();
}
