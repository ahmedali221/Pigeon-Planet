import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'cashback_offer_model.dart';
import 'cashback_transaction_model.dart';
import 'discount_offer_model.dart';
import 'user_promotion_grant_model.dart';

abstract class PromotionsRepository {
  Future<Either<Failure, List<DiscountOfferModel>>> getDiscountOffers();
  Future<Either<Failure, List<CashbackOfferModel>>> getCashbackOffers();
  Future<Either<Failure, double>> getCashbackBalance();
  Future<Either<Failure, ({List<CashbackTransactionModel> items, bool hasMore})>>
      getCashbackTransactions({int page = 1});
  Future<Either<Failure, ({List<UserPromotionGrantModel> items, bool hasMore})>>
      getMyGrants({int page = 1});
}
