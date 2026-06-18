import 'product_model.dart';

class MarketFeedResult {
  final List<ProductModel> products;
  final String? nextCursor;

  const MarketFeedResult({required this.products, this.nextCursor});
}
