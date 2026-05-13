enum PigeonGender { male, female }

class PigeonModel {
  final int? id;
  final String ringNumber;
  final String breed;
  final PigeonGender gender;
  final List<String> photoPaths;
  final String? videoPath;
  final DateTime? hatchDate;
  final List<String> raceResults;
  final String? qrData;
  final String? thumbnailUrl;

  const PigeonModel({
    this.id,
    required this.ringNumber,
    required this.breed,
    required this.gender,
    this.photoPaths = const [],
    this.videoPath,
    this.hatchDate,
    this.raceResults = const [],
    this.qrData,
    this.thumbnailUrl,
  });

  factory PigeonModel.fromJson(Map<String, dynamic> json) => PigeonModel(
        id: json['id'] as int?,
        ringNumber: json['ring_number'] as String? ?? '',
        breed: json['colour'] as String? ?? '',
        gender: (json['gender'] as String?) == 'female'
            ? PigeonGender.female
            : PigeonGender.male,
        thumbnailUrl: json['thumbnail_url'] as String?,
        hatchDate: json['birthday'] != null
            ? DateTime.tryParse(json['birthday'] as String)
            : null,
      );

  PigeonModel copyWith({
    int? id,
    String? ringNumber,
    String? breed,
    PigeonGender? gender,
    List<String>? photoPaths,
    String? videoPath,
    DateTime? hatchDate,
    List<String>? raceResults,
    String? qrData,
    String? thumbnailUrl,
  }) =>
      PigeonModel(
        id: id ?? this.id,
        ringNumber: ringNumber ?? this.ringNumber,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        photoPaths: photoPaths ?? this.photoPaths,
        videoPath: videoPath ?? this.videoPath,
        hatchDate: hatchDate ?? this.hatchDate,
        raceResults: raceResults ?? this.raceResults,
        qrData: qrData ?? this.qrData,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      );
}
