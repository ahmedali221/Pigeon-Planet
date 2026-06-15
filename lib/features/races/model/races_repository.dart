import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'race_model.dart';

abstract class RacesRepository {
  Future<Either<Failure, List<RaceModel>>> getRaces({
    int page,
    String? seasonYear,
    String? stationName,
  });
  Future<Either<Failure, RaceModel>> getRaceDetail(int raceId);
  Future<Either<Failure, List<RaceResultModel>>> getRaceResults(
    int raceId, {
    int page,
  });
  Future<Either<Failure, List<RaceResultModel>>> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int page,
  });
}
