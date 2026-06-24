import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'comment_model.dart';
import 'datasources/ratings_remote_datasource.dart';
import 'rating_model.dart';
import 'ratings_repository.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final RatingsRemoteDataSource _dataSource;

  const RatingsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, RatingPageResult>> getAssetRatings(
    int assetId, {
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getAssetRatings(assetId, page: page));

  @override
  Future<Either<Failure, void>> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  }) =>
      _wrapVoid(() => _dataSource.createAssetRating(
            assetId: assetId,
            stars: stars,
            commentText: commentText,
          ));

  @override
  Future<Either<Failure, RatingPageResult>> getSellerRatings(
    int sellerId, {
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getSellerRatings(sellerId, page: page));

  @override
  Future<Either<Failure, void>> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  }) =>
      _wrapVoid(() => _dataSource.createSellerRating(
            sellerId: sellerId,
            stars: stars,
            commentText: commentText,
          ));

  @override
  Future<Either<Failure, CommentPageResult>> getAssetComments(
    int assetId, {
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getAssetComments(assetId, page: page));

  @override
  Future<Either<Failure, void>> createAssetComment({
    required int assetId,
    required String text,
  }) =>
      _wrapVoid(() => _dataSource.createAssetComment(assetId: assetId, text: text));

  @override
  Future<Either<Failure, CommentPageResult>> getSellerComments(
    int sellerId, {
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getSellerComments(sellerId, page: page));

  @override
  Future<Either<Failure, void>> createSellerComment({
    required int sellerId,
    required String text,
  }) =>
      _wrapVoid(() => _dataSource.createSellerComment(sellerId: sellerId, text: text));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Future<Either<Failure, void>> _wrapVoid(Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }
}
