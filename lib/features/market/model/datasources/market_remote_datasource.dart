import '../product_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<ProductModel>> getProducts(String assetType, {int page = 1, String? query});
}
