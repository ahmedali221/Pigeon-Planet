import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'race_model.dart';

abstract class RacesRepository {
  Future<Either<Failure, RacePage>> getRaces({
    int page,
    String? seasonYear,
    String? stationName,
  });
  Future<Either<Failure, RaceModel>> getRaceDetail(int raceId);
  Future<Either<Failure, RaceResultPage>> getRaceResults(
    int raceId, {
    int page,
  });
  Future<Either<Failure, RaceResultPage>> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int? raceId,
    String? clubName,
    String? country,
    String? seasonYear,
    String? stationName,
    String? rank,
    String? pointName,
    String? hobbyistName,
    int page,
  });
}
