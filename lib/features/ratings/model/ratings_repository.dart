import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'comment_model.dart';
import 'datasources/ratings_remote_datasource.dart';
import 'rating_model.dart';

abstract class RatingsRepository {
  Future<Either<Failure, RatingPageResult>> getAssetRatings(
    int assetId, {
    int page = 1,
  });
  Future<Either<Failure, void>> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  });
  Future<Either<Failure, RatingPageResult>> getSellerRatings(
    int sellerId, {
    int page = 1,
  });
  Future<Either<Failure, void>> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  });
  Future<Either<Failure, CommentPageResult>> getAssetComments(
    int assetId, {
    int page = 1,
  });
  Future<Either<Failure, void>> createAssetComment({
    required int assetId,
    required String text,
  });
  Future<Either<Failure, CommentPageResult>> getSellerComments(
    int sellerId, {
    int page = 1,
  });
  Future<Either<Failure, void>> createSellerComment({
    required int sellerId,
    required String text,
  });
}
