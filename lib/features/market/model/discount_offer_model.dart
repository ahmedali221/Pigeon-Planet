class DiscountOfferModel {
  final int id;
  final String title;
  final String valueType; // 'percentage' | 'fixed_amount'
  final double value;
  final String targetType; // 'all' | 'category' | 'asset'

  const DiscountOfferModel({
    required this.id,
    required this.title,
    required this.valueType,
    required this.value,
    required this.targetType,
  });

  factory DiscountOfferModel.fromJson(Map<String, dynamic> json) =>
      DiscountOfferModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        valueType: json['value_type'] as String? ?? 'percentage',
        value: double.tryParse(json['value']?.toString() ?? '0') ?? 0.0,
        targetType: json['target_type'] as String? ?? 'all',
      );

  String get displayLabel {
    final v = value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return valueType == 'percentage' ? 'خصم $v%' : 'خصم $v ج.م';
  }
}
