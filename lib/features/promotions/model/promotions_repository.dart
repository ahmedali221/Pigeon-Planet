import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'cashback_transaction_model.dart';

abstract class PromotionsRepository {
  Future<Either<Failure, List<CashbackTransactionModel>>>
      getCashbackTransactions();
  Future<Either<Failure, double>> getCashbackBalance();
}
