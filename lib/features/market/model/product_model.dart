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
  final String status; // available | sold | inactive

  // Legacy fields kept so mock data still compiles without changes
  final List<String> benefits;
  final bool isBestSeller;
  final int seed;

  // Feed source ('following' | 'discovery' | null for category fetches)
  final String? source;

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
    this.status = 'available',
    this.benefits = const [],
    this.isBestSeller = false,
    this.seed = 0,
    this.source,
    this.ringNumber = '',
    this.gender = '',
    this.colour = '',
    this.birthday,
    this.achievements = '',
    this.flyingSpeed,
    this.staminaAbility = '',
  });

  bool get isAvailable => status == 'available';
  bool get isSold => status == 'sold';
  bool get isInactive => status == 'inactive';

  factory ProductModel.fromJson(Map<String, dynamic> json, String categoryId) {
    final id = json['id']?.toString() ?? '';
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    // Extract thumbnail from media array
    final imagesList = (json['media'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((m) => (m['media_type'] as String? ?? 'image') == 'image')
        .toList();
    final primary = imagesList.where((e) => e['is_primary'] == true).firstOrNull;
    final thumbUrl = (primary ?? (imagesList.isNotEmpty ? imagesList.first : null))?['media_url'] as String?;

    return ProductModel(
      id: id,
      categoryId: categoryId,
      // Non-bird products return 'title'; birds return both 'title' and 'name'
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      count: json['count'] as int? ?? 0,
      thumbnailUrl: thumbUrl,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'available',
      seed: int.tryParse(id) ?? 0,
      source: json['source'] as String?,
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

  ProductModel copyWith({bool? isFavorite, double? price, String? status}) =>
      ProductModel(
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
        status: status ?? this.status,
        benefits: benefits,
        isBestSeller: isBestSeller,
        seed: seed,
        source: source,
        ringNumber: ringNumber,
        gender: gender,
        colour: colour,
        birthday: birthday,
        achievements: achievements,
        flyingSpeed: flyingSpeed,
        staminaAbility: staminaAbility,
      );
}
