class DiscountOfferModel {
  final int id;
  final String title;
  final String description;
  final String valueType;
  final String value;
  final String targetType;
  final String triggerType;
  final int? asset;
  final String? category;
  final String minimumOrderPrice;
  final bool isActive;
  final int priority;
  final DateTime created;

  const DiscountOfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.valueType,
    required this.value,
    required this.targetType,
    required this.triggerType,
    this.asset,
    this.category,
    required this.minimumOrderPrice,
    required this.isActive,
    required this.priority,
    required this.created,
  });

  factory DiscountOfferModel.fromJson(Map<String, dynamic> json) =>
      DiscountOfferModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        valueType: json['value_type'] as String? ?? '',
        value: json['value'] as String? ?? '0',
        targetType: json['target_type'] as String? ?? 'all',
        triggerType: json['trigger_type'] as String? ?? 'global',
        asset: json['asset'] as int?,
        category: json['category'] as String?,
        minimumOrderPrice: json['minimum_order_price'] as String? ?? '0',
        isActive: json['is_active'] as bool? ?? false,
        priority: json['priority'] as int? ?? 0,
        created: json['created'] != null
            ? DateTime.tryParse(json['created'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  String get displayValue =>
      valueType == 'percentage' ? '$value%' : '$value ج.م';

  String get displayTarget {
    if (targetType == 'all') return 'جميع المنتجات';
    if (targetType == 'category') return category ?? 'فئة';
    return 'منتج #${asset ?? ''}';
  }
}
