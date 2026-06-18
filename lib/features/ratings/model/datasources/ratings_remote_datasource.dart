import '../comment_model.dart';
import '../rating_model.dart';

abstract class RatingsRemoteDataSource {
  Future<List<RatingModel>> getAssetRatings(int assetId);
  Future<void> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  });
  Future<List<RatingModel>> getSellerRatings(int sellerId);
  Future<void> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  });
  Future<List<CommentModel>> getAssetComments(int assetId);
  Future<void> createAssetComment({
    required int assetId,
    required String text,
  });
  Future<List<CommentModel>> getSellerComments(int sellerId);
  Future<void> createSellerComment({
    required int sellerId,
    required String text,
  });
}
