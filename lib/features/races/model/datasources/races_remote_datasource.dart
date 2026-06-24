import '../race_model.dart';

abstract class RacesRemoteDataSource {
  Future<RacePage> getRaces({int page, String? seasonYear, String? stationName});
  Future<RaceModel> getRaceDetail(int raceId);
  Future<RaceResultPage> getRaceResults(int raceId, {int page});
  Future<RaceResultPage> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int? raceId,
    int page,
  });
}
