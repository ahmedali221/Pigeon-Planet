import '../cashback_offer_model.dart';
import '../discount_offer_model.dart';
import '../market_feed_result.dart';
import '../product_model.dart';

abstract class MarketRemoteDataSource {
  Future<List<ProductModel>> getProducts(String assetType, {int page = 1, String? query, String? ordering});
  Future<MarketFeedResult> getFeedMarket({String? cursor});
  Future<List<DiscountOfferModel>> getDiscountOffers();
  Future<List<CashbackOfferModel>> getCashbackOffers();
}
