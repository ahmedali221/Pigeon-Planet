import 'package:equatable/equatable.dart';

class SellerProductModel extends Equatable {
  final int id;
  final String title;
  final String description;
  final double price;
  final int count;
  final String status; // available | sold | inactive
  final bool isMarketListed;
  final bool isForAuction;
  final String category; // supplies | accessories | feeds | supplements
  final int ownerId;
  final List<String> imageUrls;
  final DateTime? created;
  final double? rating;
  final int? reviewCount;

  const SellerProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.count,
    required this.status,
    required this.isMarketListed,
    this.isForAuction = false,
    required this.category,
    required this.ownerId,
    this.imageUrls = const [],
    this.created,
    this.rating,
    this.reviewCount,
  });

  static const categoryNames = {
    'supplies': 'مستلزمات',
    'accessories': 'إكسسوارات',
    'feeds': 'أعلاف',
    'supplements': 'مكملات',
  };

  static const statusNames = {
    'available': 'متاح',
    'sold': 'مباع',
    'inactive': 'غير نشط',
  };

  String get categoryDisplayName => categoryNames[category] ?? category;
  String get statusDisplayName => statusNames[status] ?? status;
  bool get isAvailable => status == 'available';
  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory SellerProductModel.fromJson(Map<String, dynamic> json, String category) {
    final ownerRaw = json['owner'];
    final ownerId = ownerRaw is Map
        ? (ownerRaw['id'] as int? ?? 0)
        : (ownerRaw as int? ?? 0);

    final images = (json['media'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((m) => (m['media_type'] as String? ?? 'image') == 'image')
        .map((e) => e['media_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    return SellerProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      count: json['count'] as int? ?? 0,
      status: json['status'] as String? ?? 'available',
      isMarketListed: json['is_market_listed'] as bool? ?? false,
      isForAuction: json['is_for_auction'] as bool? ?? false,
      category: category,
      ownerId: ownerId,
      imageUrls: images,
      created: json['created'] != null
          ? DateTime.tryParse(json['created'] as String)
          : null,
      rating: double.tryParse((json['rating'] ?? json['avg_rating'])?.toString() ?? ''),
      reviewCount: json['review_count'] as int? ?? json['ratings_count'] as int?,
    );
  }

  SellerProductModel copyWith({
    String? title,
    String? description,
    double? price,
    int? count,
    String? status,
    bool? isMarketListed,
    bool? isForAuction,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
  }) =>
      SellerProductModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        price: price ?? this.price,
        count: count ?? this.count,
        status: status ?? this.status,
        isMarketListed: isMarketListed ?? this.isMarketListed,
        isForAuction: isForAuction ?? this.isForAuction,
        category: category,
        ownerId: ownerId,
        imageUrls: imageUrls ?? this.imageUrls,
        created: created,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
      );

  @override
  List<Object?> get props => [
        id, category, title, price, count, status,
        isMarketListed, isForAuction, ownerId, created, rating, reviewCount,
      ];
}
