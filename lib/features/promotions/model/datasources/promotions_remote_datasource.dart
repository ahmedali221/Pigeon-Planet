import '../cashback_transaction_model.dart';

abstract class PromotionsRemoteDataSource {
  Future<List<CashbackTransactionModel>> fetchCashbackTransactions();
  Future<double> fetchCashbackBalance();
}
