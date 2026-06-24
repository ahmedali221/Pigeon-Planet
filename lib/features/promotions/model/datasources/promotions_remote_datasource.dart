import '../cashback_offer_model.dart';
import '../cashback_transaction_model.dart';
import '../discount_offer_model.dart';
import '../user_promotion_grant_model.dart';

abstract class PromotionsRemoteDataSource {
  Future<List<DiscountOfferModel>> fetchDiscountOffers();
  Future<List<CashbackOfferModel>> fetchCashbackOffers();
  Future<double> fetchCashbackBalance();
  Future<({List<CashbackTransactionModel> items, bool hasMore})>
      fetchCashbackTransactions({int page = 1});
  Future<({List<UserPromotionGrantModel> items, bool hasMore})> fetchMyGrants(
      {int page = 1});
}
