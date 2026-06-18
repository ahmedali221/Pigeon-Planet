class CashbackTransactionModel {
  final int id;
  final double amount;
  final String transactionType; // earned | redeemed | refunded | admin_adjustment
  final String? description;
  final DateTime created;

  const CashbackTransactionModel({
    required this.id,
    required this.amount,
    required this.transactionType,
    this.description,
    required this.created,
  });

  bool get isCredit =>
      transactionType == 'earned' ||
      transactionType == 'refunded' ||
      (transactionType == 'admin_adjustment' && amount > 0);

  factory CashbackTransactionModel.fromJson(Map<String, dynamic> json) =>
      CashbackTransactionModel(
        id: json['id'] as int? ?? 0,
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
        transactionType: json['transaction_type'] as String? ?? 'earned',
        description:
            json['note'] as String? ?? json['description'] as String?,
        created: DateTime.tryParse(json['created'] as String? ?? '') ??
            DateTime.now(),
      );

  String get typeLabel => switch (transactionType) {
        'earned' => '\u0645\u0643\u062a\u0633\u0628',
        'redeemed' => '\u0645\u0633\u062a\u062e\u062f\u0645',
        'refunded' => '\u0645\u0633\u062a\u0631\u062c\u0639',
        'admin_adjustment' => '\u062a\u0639\u062f\u064a\u0644',
        _ => transactionType,
      };
}
