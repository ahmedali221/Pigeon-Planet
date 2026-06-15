class SellerProductPayload {
  final String category;
  final String title;
  final String description;
  final String price;
  final int count;
  final bool isMarketListed;
  final List<String> imageUrls;

  const SellerProductPayload({
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.count,
    this.isMarketListed = true,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'count': count,
        'is_market_listed': isMarketListed,
        if (imageUrls.isNotEmpty)
          'images': imageUrls.asMap().entries
              .map((e) => {
                    'image_url': e.value,
                    'is_primary': e.key == 0,
                    'order': e.key,
                  })
              .toList(),
      };
}

class SellerProductUpdatePayload {
  final String? title;
  final String? description;
  final String? price;
  final int? count;
  final bool? isMarketListed;
  final String? status;
  final List<String>? imageUrls;

  const SellerProductUpdatePayload({
    this.title,
    this.description,
    this.price,
    this.count,
    this.isMarketListed,
    this.status,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (count != null) 'count': count,
        if (isMarketListed != null) 'is_market_listed': isMarketListed,
        if (status != null) 'status': status,
        if (imageUrls != null)
          'images': imageUrls!.asMap().entries
              .map((e) => {
                    'image_url': e.value,
                    'is_primary': e.key == 0,
                    'order': e.key,
                  })
              .toList(),
      };
}
