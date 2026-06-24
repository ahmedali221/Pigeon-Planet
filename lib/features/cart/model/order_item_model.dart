import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final int id;
  final int? orderId;
  final int assetId;
  final String title;
  final String? assetCategory;
  final String? assetStatus;
  final List<String> assetMediaUrls;
  final double? assetPrice;
  final bool? isMarketListed;
  final int? assetCount;
  final int sellerId;
  final String sellerNickname;
  final int quantity;
  final double unitPrice;
  final double grossTotal;
  final int? discountOfferId;
  final double discountAmount;
  final int? cashbackOfferId;
  final double cashbackRedeemedAmount;
  final double cashbackEarnedAmount;
  final double total;
  final String status;
  final DateTime? created;
  final DateTime? modified;

  const OrderItemModel({
    required this.id,
    this.orderId,
    required this.assetId,
    required this.title,
    this.assetCategory,
    this.assetStatus,
    this.assetMediaUrls = const [],
    this.assetPrice,
    this.isMarketListed,
    this.assetCount,
    required this.sellerId,
    required this.sellerNickname,
    required this.quantity,
    required this.unitPrice,
    required this.grossTotal,
    this.discountOfferId,
    required this.discountAmount,
    this.cashbackOfferId,
    required this.cashbackRedeemedAmount,
    required this.cashbackEarnedAmount,
    required this.total,
    required this.status,
    this.created,
    this.modified,
  });

  bool get hasDiscount => discountAmount > 0;
  bool get hasCashbackEarned => cashbackEarnedAmount > 0;
  bool get hasCashbackRedeemed => cashbackRedeemedAmount > 0;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend sends two shapes depending on the endpoint:
    //   OrderItemSummarySerializer (checkout/order-summary): flat asset_id, title, seller_id, unit_price, total
    //   OrderItemSerializer (order-detail/seller-items): nested asset{}, int seller, unit_price_snapshot, total_price
    final asset = json['asset'] as Map<String, dynamic>?;
    final media = (asset?['media'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((m) => m['media_url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order'] as int?,
      assetId: json['asset_id'] as int? ?? asset?['id'] as int? ?? 0,
      title: json['title'] as String? ?? asset?['title'] as String? ?? '',
      assetCategory: asset?['category'] as String?,
      assetStatus: asset?['status'] as String?,
      assetMediaUrls: media,
      assetPrice: double.tryParse(asset?['price']?.toString() ?? ''),
      isMarketListed: asset?['is_market_listed'] as bool?,
      assetCount: asset?['count'] as int?,
      sellerId: json['seller_id'] as int? ?? json['seller'] as int? ?? 0,
      sellerNickname: json['seller_nickname'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: double.tryParse(
            (json['unit_price'] ?? json['unit_price_snapshot'])?.toString() ?? '',
          ) ??
          0.0,
      grossTotal: double.tryParse(json['gross_total']?.toString() ?? '') ?? 0.0,
      discountOfferId: json['discount_offer'] as int?,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0.0,
      cashbackOfferId: json['cashback_offer'] as int?,
      cashbackRedeemedAmount: double.tryParse(
              json['cashback_redeemed_amount']?.toString() ?? '') ??
          0.0,
      cashbackEarnedAmount: double.tryParse(
              json['cashback_earned_amount']?.toString() ?? '') ??
          0.0,
      total: double.tryParse(
            (json['total'] ?? json['total_price'])?.toString() ?? '',
          ) ??
          0.0,
      status: json['status'] as String? ?? 'pending_seller',
      created: DateTime.tryParse(json['created'] as String? ?? ''),
      modified: DateTime.tryParse(json['modified'] as String? ?? ''),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'pending_seller':
        return 'في انتظار البائع';
      case 'awaiting_payment_review':
        return 'بانتظار مراجعة الدفع';
      case 'ready_handoff':
        return 'جاهز للتسليم';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        assetId,
        title,
        assetCategory,
        assetStatus,
        assetMediaUrls,
        assetPrice,
        isMarketListed,
        assetCount,
        sellerId,
        sellerNickname,
        quantity,
        unitPrice,
        grossTotal,
        discountOfferId,
        discountAmount,
        cashbackOfferId,
        cashbackRedeemedAmount,
        cashbackEarnedAmount,
        total,
        status,
        created,
        modified,
      ];
}
