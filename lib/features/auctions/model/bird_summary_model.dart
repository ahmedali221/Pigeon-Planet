class BirdSummaryModel {
  final int id;
  final String name;
  final String ringNumber;
  final String gender;
  final String colour;
  final DateTime? birthday;
  final String achievements;
  final double? flyingSpeed;
  final String staminaAbility;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String? videoUrl;
  final int? sellerId;
  final String sellerNickname;

  const BirdSummaryModel({
    required this.id,
    required this.name,
    required this.ringNumber,
    required this.gender,
    required this.colour,
    this.birthday,
    this.achievements = '',
    this.flyingSpeed,
    this.staminaAbility = '',
    this.description = '',
    this.price = 0.0,
    this.imageUrls = const [],
    this.videoUrl,
    this.sellerId,
    this.sellerNickname = '',
  });

  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory BirdSummaryModel.fromJson(Map<String, dynamic> json) =>
      BirdSummaryModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        ringNumber: json['ring_number'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        colour: json['colour'] as String? ?? '',
        birthday: json['birthday'] != null
            ? DateTime.tryParse(json['birthday'] as String)
            : null,
        achievements: json['achievements'] as String? ?? '',
        flyingSpeed: json['flying_speed'] != null
            ? double.tryParse(json['flying_speed'].toString())
            : null,
        staminaAbility: json['stamina_ability'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price'] != null
            ? double.tryParse(json['price'].toString()) ?? 0.0
            : 0.0,
        imageUrls: (json['media'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .where((m) => (m['media_type'] as String? ?? 'image') == 'image')
            .map((m) => m['media_url'] as String? ?? '')
            .where((url) => url.isNotEmpty)
            .toList(),
        videoUrl: (json['media'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .where((m) => m['media_type'] == 'video')
            .map((m) => m['media_url'] as String? ?? '')
            .where((url) => url.isNotEmpty)
            .firstOrNull,
        sellerId: json['seller_id'] as int? ?? json['owner'] as int?,
        sellerNickname: json['seller_nickname'] as String? ?? '',
      );
}
