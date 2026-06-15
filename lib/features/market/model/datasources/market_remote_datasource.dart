import '../../../../features/auctions/model/bird_summary_model.dart';
import '../product_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<ProductModel>> getProducts(String assetType, {int page = 1, String? query});
  Future<List<BirdSummaryModel>> getBirds({int page = 1, String? query});
}
