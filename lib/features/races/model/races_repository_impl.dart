import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'datasources/races_remote_datasource.dart';
import 'race_model.dart';
import 'races_repository.dart';

class RacesRepositoryImpl implements RacesRepository {
  final RacesRemoteDataSource _dataSource;

  const RacesRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<RaceModel>>> getRaces({
    int page = 1,
    String? seasonYear,
    String? stationName,
  }) async {
    try {
      final list = await _dataSource.getRaces(
        page: page,
        seasonYear: seasonYear,
        stationName: stationName,
      );
      return Right(list);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, RaceModel>> getRaceDetail(int raceId) async {
    try {
      final race = await _dataSource.getRaceDetail(raceId);
      return Right(race);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RaceResultModel>>> getRaceResults(
    int raceId, {
    int page = 1,
  }) async {
    try {
      final list = await _dataSource.getRaceResults(raceId, page: page);
      return Right(list);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<RaceResultModel>>> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int page = 1,
  }) async {
    try {
      final list = await _dataSource.searchResults(
        q: q,
        birdRingNumber: birdRingNumber,
        competitorName: competitorName,
        page: page,
      );
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
