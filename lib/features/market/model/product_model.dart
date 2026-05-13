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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String categoryId) {
    final id = json['id']?.toString() ?? '';
    final price = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    return ProductModel(
      id: id,
      categoryId: categoryId,
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: price,
      count: json['count'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      seed: int.tryParse(id) ?? 0,
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
      );
}
