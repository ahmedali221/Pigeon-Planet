import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'auction_model.dart';
import 'auctions_repository.dart';
import 'bid_model.dart';
import 'datasources/auctions_remote_datasource.dart';

class AuctionsRepositoryImpl implements AuctionsRepository {
  final AuctionsRemoteDataSource _dataSource;

  const AuctionsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AuctionModel>>> getAuctions({int page = 1}) =>
      _wrap(() => _dataSource.getAuctions(page: page));

  @override
  Future<Either<Failure, List<AuctionModel>>> getActiveAuctions() =>
      _wrap(() => _dataSource.getActiveAuctions());

  @override
  Future<Either<Failure, List<AuctionModel>>> getEndingSoon(
          {int minutes = 60}) =>
      _wrap(() => _dataSource.getEndingSoon(minutes: minutes));

  @override
  Future<Either<Failure, List<AuctionModel>>> getMyAuctions() =>
      _wrap(() => _dataSource.getMyAuctions());

  @override
  Future<Either<Failure, AuctionModel>> getAuctionDetail(int id) =>
      _wrap(() => _dataSource.getAuctionDetail(id));

  @override
  Future<Either<Failure, BidModel>> placeBid(int itemId, double amount) =>
      _wrap(() => _dataSource.placeBid(itemId, amount));

  @override
  Future<Either<Failure, List<BidModel>>> getBidsForItem(int itemId) =>
      _wrap(() => _dataSource.getBidsForItem(itemId));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
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
