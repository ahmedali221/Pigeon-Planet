class CashbackOfferModel {
  final int id;
  final String title;
  final String valueType; // 'percentage' | 'fixed_amount'
  final double earnValue;
  final String targetType; // 'all' | 'category' | 'asset'

  const CashbackOfferModel({
    required this.id,
    required this.title,
    required this.valueType,
    required this.earnValue,
    required this.targetType,
  });

  factory CashbackOfferModel.fromJson(Map<String, dynamic> json) =>
      CashbackOfferModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        valueType: json['value_type'] as String? ?? 'percentage',
        earnValue: double.tryParse(
                json['earn_value']?.toString() ??
                json['value']?.toString() ??
                '0') ??
            0.0,
        targetType: json['target_type'] as String? ?? 'all',
      );

  String get displayLabel {
    final v = earnValue == earnValue.truncateToDouble()
        ? earnValue.toInt().toString()
        : earnValue.toStringAsFixed(1);
    return valueType == 'percentage' ? 'كاش باك $v%' : 'كاش باك $v ج.م';
  }
}
