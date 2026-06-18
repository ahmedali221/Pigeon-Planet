import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'comment_model.dart';
import 'rating_model.dart';

abstract class RatingsRepository {
  Future<Either<Failure, List<RatingModel>>> getAssetRatings(int assetId);
  Future<Either<Failure, void>> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  });
  Future<Either<Failure, List<RatingModel>>> getSellerRatings(int sellerId);
  Future<Either<Failure, void>> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  });
  Future<Either<Failure, List<CommentModel>>> getAssetComments(int assetId);
  Future<Either<Failure, void>> createAssetComment({
    required int assetId,
    required String text,
  });
  Future<Either<Failure, List<CommentModel>>> getSellerComments(int sellerId);
  Future<Either<Failure, void>> createSellerComment({
    required int sellerId,
    required String text,
  });
}
