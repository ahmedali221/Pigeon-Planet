import 'discount_offer_model.dart';

class CashbackOfferModel extends DiscountOfferModel {
  final String allowedRedemptionAmount;

  const CashbackOfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.valueType,
    required super.value,
    required super.targetType,
    required super.triggerType,
    super.asset,
    super.category,
    required super.minimumOrderPrice,
    required super.isActive,
    required super.priority,
    required super.created,
    required this.allowedRedemptionAmount,
  });

  factory CashbackOfferModel.fromJson(Map<String, dynamic> json) =>
      CashbackOfferModel(
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
        allowedRedemptionAmount:
            json['allowed_redemption_amount'] as String? ?? '0',
      );
}
