class CashbackTransactionModel {
  final int id;
  final double amount;
  final String transactionType; // 'earned' | 'redeemed' | 'adjustment'
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
      transactionType == 'earned' || transactionType == 'adjustment' && amount > 0;

  factory CashbackTransactionModel.fromJson(Map<String, dynamic> json) =>
      CashbackTransactionModel(
        id: json['id'] as int? ?? 0,
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
        transactionType: json['transaction_type'] as String? ?? 'earned',
        description: json['description'] as String?,
        created: DateTime.tryParse(json['created'] as String? ?? '') ??
            DateTime.now(),
      );

  String get typeLabel => switch (transactionType) {
        'earned' => 'مكتسب',
        'redeemed' => 'مستخدم',
        'adjustment' => 'تعديل',
        _ => transactionType,
      };
}
