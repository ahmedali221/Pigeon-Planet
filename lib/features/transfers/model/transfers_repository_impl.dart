import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../home/model/seller_model.dart';
import 'datasources/transfers_remote_datasource.dart';
import 'ownership_transfer_model.dart';
import 'transfers_repository.dart';

class TransfersRepositoryImpl implements TransfersRepository {
  final TransfersRemoteDataSource _dataSource;

  const TransfersRepositoryImpl(this._dataSource);

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    return ServerFailure(e.message);
  }

  @override
  Future<Either<Failure, List<OwnershipTransferModel>>> getTransfers({
    int? assetId,
  }) async {
    try {
      return Right(await _dataSource.getTransfers(assetId: assetId));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, OwnershipTransferModel>> createTransfer({
    required int assetId,
    required int toProfileId,
    String? note,
  }) async {
    try {
      return Right(await _dataSource.createTransfer(
        assetId: assetId,
        toProfileId: toProfileId,
        note: note,
      ));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SellerModel>>> searchSellers(
      String query) async {
    try {
      return Right(await _dataSource.searchSellers(query));
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
