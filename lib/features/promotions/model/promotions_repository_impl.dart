import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'cashback_offer_model.dart';
import 'cashback_transaction_model.dart';
import 'datasources/promotions_remote_datasource.dart';
import 'discount_offer_model.dart';
import 'promotions_repository.dart';
import 'user_promotion_grant_model.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  final PromotionsRemoteDataSource _dataSource;

  const PromotionsRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<DiscountOfferModel>>> getDiscountOffers() async {
    try {
      return Right(await _dataSource.fetchDiscountOffers());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CashbackOfferModel>>> getCashbackOffers() async {
    try {
      return Right(await _dataSource.fetchCashbackOffers());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getCashbackBalance() async {
    try {
      return Right(await _dataSource.fetchCashbackBalance());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ({List<CashbackTransactionModel> items, bool hasMore})>>
      getCashbackTransactions({int page = 1}) async {
    try {
      return Right(await _dataSource.fetchCashbackTransactions(page: page));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ({List<UserPromotionGrantModel> items, bool hasMore})>>
      getMyGrants({int page = 1}) async {
    try {
      return Right(await _dataSource.fetchMyGrants(page: page));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
