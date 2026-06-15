enum PigeonGender { male, female }

enum StaminaAbility {
  excellent('excellent', 'ممتاز'),
  verygood('verygood', 'جيد جداً'),
  good('good', 'جيد');

  const StaminaAbility(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class PigeonModel {
  final int? id;
  final String ringNumber;
  final String name;
  final String breed;
  final PigeonGender gender;
  final List<String> photoPaths;
  final String? videoPath;
  final DateTime? hatchDate;
  final List<String> raceResults;
  final String? qrData;
  final String? thumbnailUrl;
  final String achievements;
  final StaminaAbility staminaAbility;
  final double price;
  final String description;
  final double? flyingSpeed;
  final bool isMarketListed;

  const PigeonModel({
    this.id,
    required this.ringNumber,
    this.name = '',
    required this.breed,
    required this.gender,
    this.photoPaths = const [],
    this.videoPath,
    this.hatchDate,
    this.raceResults = const [],
    this.qrData,
    this.thumbnailUrl,
    this.achievements = '',
    this.staminaAbility = StaminaAbility.good,
    this.price = 0.0,
    this.description = '',
    this.flyingSpeed,
    this.isMarketListed = true,
  });

  factory PigeonModel.fromJson(Map<String, dynamic> json) => PigeonModel(
        id: json['id'] as int?,
        ringNumber: json['ring_number'] as String? ?? '',
        name: json['name'] as String? ?? json['title'] as String? ?? '',
        breed: json['colour'] as String? ?? '',
        gender: (json['gender'] as String?) == 'female'
            ? PigeonGender.female
            : PigeonGender.male,
        thumbnailUrl: json['thumbnail_url'] as String?,
        videoPath: (json['video_url'] as String?)?.isNotEmpty == true
            ? json['video_url'] as String
            : null,
        hatchDate: json['birthday'] != null
            ? DateTime.tryParse(json['birthday'] as String)
            : null,
        achievements: json['achievements'] as String? ?? '',
        staminaAbility: _parseStamina(json['stamina_ability'] as String?),
        price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
        description: json['description'] as String? ?? '',
        flyingSpeed: json['flying_speed'] != null
            ? double.tryParse(json['flying_speed'].toString())
            : null,
        isMarketListed: json['is_market_listed'] as bool? ?? true,
      );

  static StaminaAbility _parseStamina(String? value) {
    switch (value) {
      case 'excellent':
        return StaminaAbility.excellent;
      case 'verygood':
        return StaminaAbility.verygood;
      default:
        return StaminaAbility.good;
    }
  }

  PigeonModel copyWith({
    int? id,
    String? ringNumber,
    String? name,
    String? breed,
    PigeonGender? gender,
    List<String>? photoPaths,
    String? videoPath,
    DateTime? hatchDate,
    List<String>? raceResults,
    String? qrData,
    String? thumbnailUrl,
    String? achievements,
    StaminaAbility? staminaAbility,
    double? price,
    String? description,
    double? flyingSpeed,
    bool? isMarketListed,
  }) =>
      PigeonModel(
        id: id ?? this.id,
        ringNumber: ringNumber ?? this.ringNumber,
        name: name ?? this.name,
        breed: breed ?? this.breed,
        gender: gender ?? this.gender,
        photoPaths: photoPaths ?? this.photoPaths,
        videoPath: videoPath ?? this.videoPath,
        hatchDate: hatchDate ?? this.hatchDate,
        raceResults: raceResults ?? this.raceResults,
        qrData: qrData ?? this.qrData,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        achievements: achievements ?? this.achievements,
        staminaAbility: staminaAbility ?? this.staminaAbility,
        price: price ?? this.price,
        description: description ?? this.description,
        flyingSpeed: flyingSpeed ?? this.flyingSpeed,
        isMarketListed: isMarketListed ?? this.isMarketListed,
      );
}
