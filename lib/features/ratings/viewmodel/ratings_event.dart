part of 'ratings_bloc.dart';

abstract class RatingsEvent extends Equatable {
  const RatingsEvent();
  @override
  List<Object?> get props => [];
}

class AssetRatingsLoadRequested extends RatingsEvent {
  final int assetId;
  const AssetRatingsLoadRequested(this.assetId);
  @override
  List<Object?> get props => [assetId];
}

class SellerRatingsLoadRequested extends RatingsEvent {
  final int sellerId;
  const SellerRatingsLoadRequested(this.sellerId);
  @override
  List<Object?> get props => [sellerId];
}

class AssetRatingSubmitted extends RatingsEvent {
  final int assetId;
  final int stars;
  final String? commentText;
  const AssetRatingSubmitted({required this.assetId, required this.stars, this.commentText});
  @override
  List<Object?> get props => [assetId, stars, commentText];
}

class SellerRatingSubmitted extends RatingsEvent {
  final int sellerId;
  final int stars;
  final String? commentText;
  const SellerRatingSubmitted({required this.sellerId, required this.stars, this.commentText});
  @override
  List<Object?> get props => [sellerId, stars, commentText];
}

class AssetCommentSubmitted extends RatingsEvent {
  final int assetId;
  final String text;
  const AssetCommentSubmitted({required this.assetId, required this.text});
  @override
  List<Object?> get props => [assetId, text];
}

class SellerCommentSubmitted extends RatingsEvent {
  final int sellerId;
  final String text;
  const SellerCommentSubmitted({required this.sellerId, required this.text});
  @override
  List<Object?> get props => [sellerId, text];
}
