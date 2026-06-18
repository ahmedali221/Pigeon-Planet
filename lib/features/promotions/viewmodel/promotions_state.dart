import 'package:equatable/equatable.dart';

import '../model/cashback_transaction_model.dart';

enum PromotionsStatus { initial, loading, loaded, error }

class PromotionsState extends Equatable {
  final PromotionsStatus status;
  final List<CashbackTransactionModel> transactions;
  final double balance;
  final String? errorMessage;

  const PromotionsState({
    this.status = PromotionsStatus.initial,
    this.transactions = const [],
    this.balance = 0.0,
    this.errorMessage,
  });

  PromotionsState copyWith({
    PromotionsStatus? status,
    List<CashbackTransactionModel>? transactions,
    double? balance,
    String? errorMessage,
  }) =>
      PromotionsState(
        status: status ?? this.status,
        transactions: transactions ?? this.transactions,
        balance: balance ?? this.balance,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, transactions, balance, errorMessage];
}
