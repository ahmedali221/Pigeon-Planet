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
  // Extended fields – club tab
  final String? country;
  final String? clubName;
  final double? points;
  final int? totalBirds;
  final String? resultLines1;
  final String? resultLines2;
  // Extended fields – OLR tab
  final String? pointName;
  final String? timeDifference;
  final int? arrivalsCount;
  final DateTime? created;
  final DateTime? modified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.country,
    this.clubName,
    this.points,
    this.totalBirds,
    this.resultLines1,
    this.resultLines2,
    this.pointName,
    this.timeDifference,
    this.arrivalsCount,
    this.created,
    this.modified,
    this.createdAt,
    this.updatedAt,
  });

  factory RaceResultModel.fromJson(Map<String, dynamic> json) {
    final raceJson = json['race'] as Map<String, dynamic>?;
    return RaceResultModel(
      id: json['id'] as int,
      raceId: raceJson?['id'] as int? ?? json['race_id'] as int?,
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
      country: json['country'] as String? ?? raceJson?['country'] as String?,
      clubName: json['club_name'] as String? ?? raceJson?['club_name'] as String?,
      points: double.tryParse(json['points']?.toString() ?? ''),
      totalBirds: json['total_birds'] as int? ?? raceJson?['total_birds'] as int?,
      resultLines1: json['result_lines_1'] as String?,
      resultLines2: json['result_lines_2'] as String?,
      pointName: json['point_name'] as String? ?? raceJson?['point_name'] as String?,
      timeDifference: json['time_difference'] as String?,
      arrivalsCount: json['arrivals_count'] as int?,
      created: DateTime.tryParse(json['created'] as String? ?? ''),
      modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
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
  final DateTime? created;
  final DateTime? modified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.created,
    this.modified,
    this.createdAt,
    this.updatedAt,
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
      created: DateTime.tryParse(json['created'] as String? ?? ''),
      modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }
}

class RacePage {
  final List<RaceModel> races;
  final bool hasMore;

  const RacePage({required this.races, required this.hasMore});
}

class RaceResultPage {
  final List<RaceResultModel> results;
  final bool hasMore;

  const RaceResultPage({required this.results, required this.hasMore});
}
