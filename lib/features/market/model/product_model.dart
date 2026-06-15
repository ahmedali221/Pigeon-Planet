class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final int count;
  final String? thumbnailUrl;
  final double rating;
  final int reviewCount;
  final bool isFavorite;

  // Legacy fields kept so mock data still compiles without changes
  final List<String> benefits;
  final bool isBestSeller;
  final int seed;

  // Bird-specific fields (null/empty for non-bird products)
  final String ringNumber;
  final String gender;
  final String colour;
  final DateTime? birthday;
  final String achievements;
  final double? flyingSpeed;
  final String staminaAbility;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    this.count = 0,
    this.thumbnailUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavorite = false,
    this.benefits = const [],
    this.isBestSeller = false,
    this.seed = 0,
    this.ringNumber = '',
    this.gender = '',
    this.colour = '',
    this.birthday,
    this.achievements = '',
    this.flyingSpeed,
    this.staminaAbility = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String categoryId) {
    final id = json['id']?.toString() ?? '';
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    // Extract thumbnail: prefer is_primary image from images array, else first image
    final imagesList = (json['images'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final primary = imagesList.where((e) => e['is_primary'] == true).firstOrNull;
    final thumbUrl = (primary ?? (imagesList.isNotEmpty ? imagesList.first : null))?['image_url'] as String?
        ?? json['thumbnail_url'] as String?;

    return ProductModel(
      id: id,
      categoryId: categoryId,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      count: json['count'] as int? ?? 0,
      thumbnailUrl: thumbUrl,
      seed: int.tryParse(id) ?? 0,
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
    );
  }

  ProductModel copyWith({bool? isFavorite, double? price}) => ProductModel(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price ?? this.price,
        count: count,
        thumbnailUrl: thumbnailUrl,
        rating: rating,
        reviewCount: reviewCount,
        isFavorite: isFavorite ?? this.isFavorite,
        benefits: benefits,
        isBestSeller: isBestSeller,
        seed: seed,
        ringNumber: ringNumber,
        gender: gender,
        colour: colour,
        birthday: birthday,
        achievements: achievements,
        flyingSpeed: flyingSpeed,
        staminaAbility: staminaAbility,
      );
}
