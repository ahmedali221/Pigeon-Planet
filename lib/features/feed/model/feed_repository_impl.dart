import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../home/model/seller_model.dart';
import 'datasources/feed_remote_datasource.dart';
import 'feed_auction_item_model.dart';
import 'feed_repository.dart';
import 'seller_block_model.dart';
import 'seller_follow_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _dataSource;

  const FeedRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, void>> followSeller(int sellerId) async {
    try {
      await _dataSource.followSeller(sellerId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unfollowSeller(int sellerId) async {
    try {
      await _dataSource.unfollowSeller(sellerId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SellerFollowModel>>> getFollowing() async {
    try {
      return Right(await _dataSource.getFollowing());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SellerModel>>> getSuggestions() async {
    try {
      return Right(await _dataSource.getSuggestions());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SellerBlockModel>>> getBlocks() async {
    try {
      return Right(await _dataSource.getBlocks());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> blockProfile(int profileId) async {
    try {
      await _dataSource.blockProfile(profileId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unblockProfile(int profileId) async {
    try {
      await _dataSource.unblockProfile(profileId);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, FeedAuctionResult>> getAuctionFeed({
    String? cursor,
  }) async {
    try {
      return Right(await _dataSource.getAuctionFeed(cursor: cursor));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
