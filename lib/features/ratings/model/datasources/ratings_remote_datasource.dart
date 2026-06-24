import '../comment_model.dart';
import '../rating_model.dart';

typedef RatingPageResult = ({List<RatingModel> items, bool hasMore});
typedef CommentPageResult = ({List<CommentModel> items, bool hasMore});

abstract class RatingsRemoteDataSource {
  Future<RatingPageResult> getAssetRatings(int assetId, {int page = 1});
  Future<void> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  });
  Future<RatingPageResult> getSellerRatings(int sellerId, {int page = 1});
  Future<void> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  });
  Future<CommentPageResult> getAssetComments(int assetId, {int page = 1});
  Future<void> createAssetComment({
    required int assetId,
    required String text,
  });
  Future<CommentPageResult> getSellerComments(int sellerId, {int page = 1});
  Future<void> createSellerComment({
    required int sellerId,
    required String text,
  });
}
