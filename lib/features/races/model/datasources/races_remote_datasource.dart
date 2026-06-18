import '../race_model.dart';

abstract class RacesRemoteDataSource {
  Future<RacePage> getRaces({int page, String? seasonYear, String? stationName});
  Future<RaceModel> getRaceDetail(int raceId);
  Future<List<RaceResultModel>> getRaceResults(int raceId, {int page});
  Future<List<RaceResultModel>> searchResults({String? q, String? birdRingNumber, String? competitorName, int page});
}
