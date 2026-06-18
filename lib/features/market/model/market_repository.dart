import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'cashback_offer_model.dart';
import 'discount_offer_model.dart';
import 'market_feed_result.dart';
import 'product_model.dart';

abstract class MarketRepository {
  Future<Either<Failure, List<ProductModel>>> getProducts(
    String assetType, {
    int page = 1,
    String? query,
    String? ordering,
  });

  Future<Either<Failure, MarketFeedResult>> getFeedMarket({String? cursor});

  Future<Either<Failure, List<DiscountOfferModel>>> getDiscountOffers();

  Future<Either<Failure, List<CashbackOfferModel>>> getCashbackOffers();
}
