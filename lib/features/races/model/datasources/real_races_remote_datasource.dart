import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../race_model.dart';
import 'races_remote_datasource.dart';

class RealRacesRemoteDataSource implements RacesRemoteDataSource {
  final DioClient _dio;

  const RealRacesRemoteDataSource(this._dio);

  @override
  Future<List<RaceModel>> getRaces({
    int page = 1,
    String? seasonYear,
    String? stationName,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      if (seasonYear != null && seasonYear.isNotEmpty) 'season_year': seasonYear,
      if (stationName != null && stationName.isNotEmpty) 'station_name': stationName,
    };
    final response = await _dio.get(ApiConstants.races, queryParameters: params);
    final data = response.data;
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items
        .map((e) => RaceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RaceModel> getRaceDetail(int raceId) async {
    final response = await _dio.get(ApiConstants.raceDetail(raceId));
    return RaceModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<RaceResultModel>> getRaceResults(int raceId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.raceResults(raceId),
      queryParameters: {'page': page},
    );
    final data = response.data;
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items
        .map((e) => RaceResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RaceResultModel>> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int page = 1,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'include_race': 'true',
      if (q != null && q.isNotEmpty) 'q': q,
      if (birdRingNumber != null && birdRingNumber.isNotEmpty)
        'bird_ring_number': birdRingNumber,
      if (competitorName != null && competitorName.isNotEmpty)
        'competitor_name': competitorName,
    };
    final response = await _dio.get(
      ApiConstants.raceResultsGlobal,
      queryParameters: params,
    );
    final data = response.data;
    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return items
        .map((e) => RaceResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
