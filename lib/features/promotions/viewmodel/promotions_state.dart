import 'package:equatable/equatable.dart';

import '../model/cashback_offer_model.dart';
import '../model/cashback_transaction_model.dart';
import '../model/discount_offer_model.dart';
import '../model/user_promotion_grant_model.dart';

enum PromotionsStatus { initial, loading, loaded, error }

class PromotionsState extends Equatable {
  final PromotionsStatus status;
  final double balance;
  final List<CashbackTransactionModel> transactions;
  final bool hasMoreTx;
  final int txPage;
  final bool loadingMoreTx;
  final List<DiscountOfferModel> discountOffers;
  final List<CashbackOfferModel> cashbackOffers;
  final List<UserPromotionGrantModel> grants;
  final bool hasMoreGrants;
  final int grantsPage;
  final bool loadingMoreGrants;
  final bool offersLoading;
  final String? errorMessage;

  const PromotionsState({
    this.status = PromotionsStatus.initial,
    this.balance = 0.0,
    this.transactions = const [],
    this.hasMoreTx = false,
    this.txPage = 1,
    this.loadingMoreTx = false,
    this.discountOffers = const [],
    this.cashbackOffers = const [],
    this.grants = const [],
    this.hasMoreGrants = false,
    this.grantsPage = 1,
    this.loadingMoreGrants = false,
    this.offersLoading = false,
    this.errorMessage,
  });

  PromotionsState copyWith({
    PromotionsStatus? status,
    double? balance,
    List<CashbackTransactionModel>? transactions,
    bool? hasMoreTx,
    int? txPage,
    bool? loadingMoreTx,
    List<DiscountOfferModel>? discountOffers,
    List<CashbackOfferModel>? cashbackOffers,
    List<UserPromotionGrantModel>? grants,
    bool? hasMoreGrants,
    int? grantsPage,
    bool? loadingMoreGrants,
    bool? offersLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      PromotionsState(
        status: status ?? this.status,
        balance: balance ?? this.balance,
        transactions: transactions ?? this.transactions,
        hasMoreTx: hasMoreTx ?? this.hasMoreTx,
        txPage: txPage ?? this.txPage,
        loadingMoreTx: loadingMoreTx ?? this.loadingMoreTx,
        discountOffers: discountOffers ?? this.discountOffers,
        cashbackOffers: cashbackOffers ?? this.cashbackOffers,
        grants: grants ?? this.grants,
        hasMoreGrants: hasMoreGrants ?? this.hasMoreGrants,
        grantsPage: grantsPage ?? this.grantsPage,
        loadingMoreGrants: loadingMoreGrants ?? this.loadingMoreGrants,
        offersLoading: offersLoading ?? this.offersLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        status,
        balance,
        transactions,
        hasMoreTx,
        txPage,
        loadingMoreTx,
        discountOffers,
        cashbackOffers,
        grants,
        hasMoreGrants,
        grantsPage,
        loadingMoreGrants,
        offersLoading,
        errorMessage,
      ];
}
