class ProductCreatePayload {
  final String category;
  final String name;
  final String description;
  final String price;
  final int count;

  const ProductCreatePayload({
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.count,
  });

  String get endpoint => '/assets/$category/';

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'count': count,
        'is_market_listed': true,
      };
}
