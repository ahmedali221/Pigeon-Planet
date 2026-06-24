import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../race_model.dart';
import 'races_remote_datasource.dart';

class RealRacesRemoteDataSource implements RacesRemoteDataSource {
  final DioClient _dio;

  const RealRacesRemoteDataSource(this._dio);

  ({List<T> items, bool hasMore}) _parsePage<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) {
      throw const ServerException('Unexpected response format');
    }
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : null);
    if (items == null) {
      throw const ServerException('Unexpected response format');
    }
    return (
      items: items.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      hasMore: data is Map && data['next'] != null,
    );
  }

  @override
  Future<RacePage> getRaces({
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
    bool hasMore = false;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
      hasMore = data['next'] != null;
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }
    return RacePage(
      races: items
          .map((e) => RaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: hasMore,
    );
  }

  @override
  Future<RaceModel> getRaceDetail(int raceId) async {
    final response = await _dio.get(ApiConstants.raceDetail(raceId));
    return RaceModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<RaceResultPage> getRaceResults(int raceId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.raceResults(raceId),
      queryParameters: {'page': page},
    );
    final pageData = _parsePage(response.data, RaceResultModel.fromJson);
    return RaceResultPage(
      results: pageData.items,
      hasMore: pageData.hasMore,
    );
  }

  @override
  Future<RaceResultPage> searchResults({
    String? q,
    String? birdRingNumber,
    String? competitorName,
    int? raceId,
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
      if (raceId != null) 'race_id': raceId,
    };
    final response = await _dio.get(
      ApiConstants.raceResultsGlobal,
      queryParameters: params,
    );
    final pageData = _parsePage(response.data, RaceResultModel.fromJson);
    return RaceResultPage(
      results: pageData.items,
      hasMore: pageData.hasMore,
    );
  }
}
