import '../seller_product_model.dart';

typedef SellerProductsPageResult = ({
  List<SellerProductModel> products,
  bool hasMore,
});

abstract class SellerProductsDataSource {
  Future<int> getSellerProfileId();

  Future<SellerProductsPageResult> getProducts({
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
