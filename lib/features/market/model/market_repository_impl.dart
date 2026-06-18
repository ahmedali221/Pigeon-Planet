import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'cashback_offer_model.dart';
import 'datasources/market_remote_datasource.dart';
import 'discount_offer_model.dart';
import 'market_feed_result.dart';
import 'market_repository.dart';
import 'product_model.dart';

class MarketRepositoryImpl implements MarketRepository {
  final MarketRemoteDataSource _dataSource;

  const MarketRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts(
    String assetType, {
    int page = 1,
    String? query,
    String? ordering,
  }) async {
    try {
      final list = await _dataSource.getProducts(
        assetType,
        page: page,
        query: query,
        ordering: ordering,
      );
      return Right(list);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MarketFeedResult>> getFeedMarket({
    String? cursor,
  }) async {
    try {
      final result = await _dataSource.getFeedMarket(cursor: cursor);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DiscountOfferModel>>> getDiscountOffers() async {
    try {
      final list = await _dataSource.getDiscountOffers();
      return Right(list);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CashbackOfferModel>>> getCashbackOffers() async {
    try {
      final list = await _dataSource.getCashbackOffers();
      return Right(list);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }
}
