enum PigeonGender {
  male('male', 'ذكر'),
  female('female', 'أنثى'),
  young('young', 'صغير');

  const PigeonGender(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

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
  final String? publicId;
  final String? qrPayloadUrl;
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
  final String status;
  final String? sellerNickname;
  final double? avgRating;
  final int? ratingsCount;
  final DateTime? created;
  final int? fatherId;
  final int? motherId;

  const PigeonModel({
    this.id,
    this.publicId,
    this.qrPayloadUrl,
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
    this.status = 'available',
    this.sellerNickname,
    this.avgRating,
    this.ratingsCount,
    this.created,
    this.fatherId,
    this.motherId,
  });

  factory PigeonModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = (json['media'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) {
        final aOrder = a['order'] as int? ?? 0;
        final bOrder = b['order'] as int? ?? 0;
        return aOrder.compareTo(bOrder);
      });

    final imageMedia = rawMedia
        .where((m) => (m['media_type'] as String? ?? 'image') == 'image')
        .toList();
    final videoMedia = rawMedia
        .where((m) => m['media_type'] == 'video')
        .firstOrNull;

    final primaryImage = imageMedia
            .where((m) => m['is_primary'] == true)
            .firstOrNull ??
        (imageMedia.isNotEmpty ? imageMedia.first : null);

    final thumbnailUrl = primaryImage?['media_url'] as String?;
    final photoPaths = imageMedia
        .map((m) => m['media_url'] as String? ?? '')
        .where((u) => u.isNotEmpty)
        .toList();
    final videoPath = videoMedia?['media_url'] as String?;

    // Seller nickname: public endpoint returns seller:{nickname}, authenticated
    // endpoint returns owner as int (no nickname — user's own bird, no need).
    final sellerNode = json['seller'];
    final sellerNickname = sellerNode is Map<String, dynamic>
        ? sellerNode['nickname'] as String?
        : json['seller_nickname'] as String? ?? json['owner_nickname'] as String?;

    return PigeonModel(
      id: json['id'] as int?,
      publicId: json['public_id'] as String?,
      qrPayloadUrl: json['qr_payload_url'] as String?,
      ringNumber: json['ring_number'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      breed: json['colour'] as String? ?? '',
      gender: _parseGender(json['gender'] as String?),
      thumbnailUrl: thumbnailUrl,
      photoPaths: photoPaths,
      videoPath: (videoPath?.isNotEmpty ?? false) ? videoPath : null,
      // authenticated uses 'birthday', public endpoint uses 'hatch_date'
      hatchDate: _parseDate(json['birthday'] ?? json['hatch_date']),
      achievements: json['achievements'] as String? ?? '',
      staminaAbility: _parseStamina(json['stamina_ability'] as String?),
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      description: json['description'] as String? ?? '',
      flyingSpeed: json['flying_speed'] != null
          ? double.tryParse(json['flying_speed'].toString())
          : null,
      isMarketListed: json['is_market_listed'] as bool? ?? true,
      status: json['status'] as String? ?? 'available',
      sellerNickname: sellerNickname,
      avgRating: double.tryParse((json['rating'] ?? json['avg_rating'])?.toString() ?? ''),
      ratingsCount: json['review_count'] as int? ?? json['ratings_count'] as int?,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      fatherId: json['father'] as int?,
      motherId: json['mother'] as int?,
    );
  }

  static PigeonGender _parseGender(String? value) {
    switch (value) {
      case 'female':
        return PigeonGender.female;
      case 'young':
        return PigeonGender.young;
      default:
        return PigeonGender.male;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

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
    String? publicId,
    String? qrPayloadUrl,
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
    String? status,
    String? sellerNickname,
    double? avgRating,
    int? ratingsCount,
    DateTime? created,
    int? fatherId,
    int? motherId,
  }) =>
      PigeonModel(
        id: id ?? this.id,
        publicId: publicId ?? this.publicId,
        qrPayloadUrl: qrPayloadUrl ?? this.qrPayloadUrl,
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
        status: status ?? this.status,
        sellerNickname: sellerNickname ?? this.sellerNickname,
        avgRating: avgRating ?? this.avgRating,
        ratingsCount: ratingsCount ?? this.ratingsCount,
        created: created ?? this.created,
        fatherId: fatherId ?? this.fatherId,
        motherId: motherId ?? this.motherId,
      );
}
