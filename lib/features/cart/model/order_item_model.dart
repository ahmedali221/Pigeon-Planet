import 'package:equatable/equatable.dart';

class OrderItemModel extends Equatable {
  final int id;
  final int assetId;
  final String title;
  final int sellerId;
  final String sellerNickname;
  final int quantity;
  final double unitPrice;
  final double total;
  final String status;

  const OrderItemModel({
    required this.id,
    required this.assetId,
    required this.title,
    required this.sellerId,
    required this.sellerNickname,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.status,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as int,
        assetId: json['asset_id'] as int,
        title: json['title'] as String? ?? '',
        sellerId: json['seller_id'] as int,
        sellerNickname: json['seller_nickname'] as String? ?? '',
        quantity: json['quantity'] as int,
        unitPrice:
            double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
        total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
        status: json['status'] as String? ?? 'pending_seller',
      );

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'تمت الموافقة';
      case 'rejected':
        return 'مرفوض';
      case 'pending_seller':
        return 'في انتظار البائع';
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
        quantity, unitPrice, total, status,
      ];
}
