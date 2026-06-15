import '../seller_product_model.dart';

abstract class SellerProductsDataSource {
  Future<int> getSellerProfileId();

  Future<List<SellerProductModel>> getProducts({
    required int profileId,
    String? category,
    int page = 1,
  });

  Future<SellerProductModel> createProduct(
      String category, Map<String, dynamic> data);

  Future<SellerProductModel> updateProduct(
      String category, int id, Map<String, dynamic> data);

  Future<void> deleteProduct(String category, int id);
}
