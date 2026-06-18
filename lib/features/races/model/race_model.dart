class RaceResultModel {
  final int id;
  final int? raceId;
  final String? raceTitle;
  final int? raceSeasonYear;
  final String? raceStationName;
  final String? raceReleaseDatetime;
  final int rank;
  final String competitorName;
  final String birdRingNumber;
  final double distanceKm;
  final double speed;
  final String arrivalDatetime;
  final int? basketNumber;

  const RaceResultModel({
    required this.id,
    this.raceId,
    this.raceTitle,
    this.raceSeasonYear,
    this.raceStationName,
    this.raceReleaseDatetime,
    required this.rank,
    required this.competitorName,
    required this.birdRingNumber,
    required this.distanceKm,
    required this.speed,
    required this.arrivalDatetime,
    this.basketNumber,
  });

  factory RaceResultModel.fromJson(Map<String, dynamic> json) {
    final raceJson = json['race'] as Map<String, dynamic>?;
    return RaceResultModel(
      id: json['id'] as int,
      raceId: raceJson?['id'] as int?,
      raceTitle: raceJson?['title'] as String?,
      raceSeasonYear: raceJson?['season_year'] as int?,
      raceStationName: raceJson?['station_name'] as String?,
      raceReleaseDatetime: raceJson?['release_datetime'] as String?,
      rank: json['rank'] as int,
      competitorName: json['competitor_name'] as String? ?? '',
      birdRingNumber: json['bird_ring_number'] as String? ?? '',
      distanceKm: double.tryParse(json['distance_km']?.toString() ?? '0') ?? 0.0,
      speed: double.tryParse(json['speed']?.toString() ?? '0') ?? 0.0,
      arrivalDatetime: json['arrival_datetime'] as String? ?? '',
      basketNumber: json['basket_number'] as int?,
    );
  }
}

class RaceModel {
  final int id;
  final String title;
  final int seasonYear;
  final String stationName;
  final String releaseDatetime;
  final String weatherCondition;
  final int totalBirds;
  final int competitorsCount;
  final double? plannedDistanceKm;
  final String coordinateX;
  final String coordinateY;
  final String notes;
  final List<RaceResultModel> results;

  const RaceModel({
    required this.id,
    required this.title,
    required this.seasonYear,
    required this.stationName,
    required this.releaseDatetime,
    required this.weatherCondition,
    required this.totalBirds,
    required this.competitorsCount,
    this.plannedDistanceKm,
    required this.coordinateX,
    required this.coordinateY,
    required this.notes,
    this.results = const [],
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>?;
    return RaceModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      seasonYear: json['season_year'] as int? ?? 0,
      stationName: json['station_name'] as String? ?? '',
      releaseDatetime: json['release_datetime'] as String? ?? '',
      weatherCondition: json['weather_condition'] as String? ?? '',
      totalBirds: json['total_birds'] as int? ?? 0,
      competitorsCount: json['competitors_count'] as int? ?? 0,
      plannedDistanceKm: json['planned_distance_km'] != null
          ? double.tryParse(json['planned_distance_km'].toString())
          : null,
      coordinateX: json['coordinate_x'] as String? ?? '',
      coordinateY: json['coordinate_y'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      results: rawResults
              ?.map((e) =>
                  RaceResultModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RacePage {
  final List<RaceModel> races;
  final bool hasMore;

  const RacePage({required this.races, required this.hasMore});
}
