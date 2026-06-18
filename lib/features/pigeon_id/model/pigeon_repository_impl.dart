import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/pigeon_remote_datasource.dart';
import 'pigeon_model.dart';
import 'pigeon_repository.dart';

class PigeonRepositoryImpl implements PigeonRepository {
  final PigeonRemoteDataSource _dataSource;

  const PigeonRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, PigeonModel>> saveBird(PigeonModel pigeon) async {
    try {
      final result = await _dataSource.saveBird(pigeon);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PigeonModel>> updateBird(
      int id, PigeonModel pigeon) async {
    try {
      final result = await _dataSource.updateBird(id, pigeon);
      return Right(result);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteBird(int id) async {
    try {
      await _dataSource.deleteBird(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PigeonModel>> fetchPublicBird(String publicId) async {
    try {
      final result = await _dataSource.fetchPublicBird(publicId);
      return Right(result);
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
