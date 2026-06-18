import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final int id;
  final int assetId;
  final String title;
  final int sellerId;
  final String sellerNickname;
  final int quantity;
  final double unitPrice;
  final double grossTotal;
  final double discountAmount;
  final double cashbackRedeemedAmount;
  final double cashbackEarnedAmount;
  final double total;
  final String status;
  final DateTime? created;

  const OrderItemModel({
    required this.id,
    required this.assetId,
    required this.title,
    required this.sellerId,
    required this.sellerNickname,
    required this.quantity,
    required this.unitPrice,
    required this.grossTotal,
    required this.discountAmount,
    required this.cashbackRedeemedAmount,
    required this.cashbackEarnedAmount,
    required this.total,
    required this.status,
    this.created,
  });

  bool get hasDiscount => discountAmount > 0;
  bool get hasCashbackEarned => cashbackEarnedAmount > 0;
  bool get hasCashbackRedeemed => cashbackRedeemedAmount > 0;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend sends two shapes depending on the endpoint:
    //   OrderItemSummarySerializer (checkout/order-summary): flat asset_id, title, seller_id, unit_price, total
    //   OrderItemSerializer (order-detail/seller-items): nested asset{}, int seller, unit_price_snapshot, total_price
    final asset = json['asset'] as Map<String, dynamic>?;
    return OrderItemModel(
      id: json['id'] as int,
      assetId: json['asset_id'] as int? ?? asset?['id'] as int? ?? 0,
      title: json['title'] as String? ?? asset?['title'] as String? ?? '',
      sellerId: json['seller_id'] as int? ?? json['seller'] as int? ?? 0,
      sellerNickname: json['seller_nickname'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: double.tryParse(
            (json['unit_price'] ?? json['unit_price_snapshot'])?.toString() ?? '',
          ) ??
          0.0,
      grossTotal: double.tryParse(json['gross_total']?.toString() ?? '') ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0.0,
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
        id, assetId, title, sellerId, sellerNickname,
        quantity, unitPrice, grossTotal, discountAmount,
        cashbackRedeemedAmount, cashbackEarnedAmount, total, status, created,
      ];
}
