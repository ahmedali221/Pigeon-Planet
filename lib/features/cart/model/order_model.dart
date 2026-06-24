import 'package:equatable/equatable.dart';

import 'order_item_model.dart';

class OrderModel extends Equatable {
  final int id;
  final String status;
  final double totalPrice;
  final String? totalAmount;
  final String? customerName;
  final String? customerUsername;
  final String? customerPhone;
  final List<int> sellersInvolved;
  final List<OrderItemModel> items;
  // item_count from list endpoint (OrderListSerializer has no items[])
  final int? itemCount;
  final DateTime? created;
  final DateTime? modified;

  const OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    this.totalAmount,
    this.customerName,
    this.customerUsername,
    this.customerPhone,
    required this.sellersInvolved,
    required this.items,
    this.itemCount,
    this.created,
    this.modified,
  });

  // Use itemCount (list endpoint) if items[] wasn't returned
  int get displayItemCount => itemCount ?? items.length;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? 'pending',
        totalPrice:
            double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
        totalAmount: json['total_amount'] as String?,
        customerName: json['customer_name'] as String?,
        customerUsername: json['customer_username'] as String?,
        customerPhone: json['customer_phone'] as String?,
        sellersInvolved: (json['sellers_involved'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        itemCount: json['item_count'] as int?,
        created: DateTime.tryParse(json['created'] as String? ?? ''),
        modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      );

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'جارٍ التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      case 'partial_rejected':
        return 'مقبول جزئياً';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props =>
      [
        id,
        status,
        totalPrice,
        totalAmount,
        customerName,
        customerUsername,
        customerPhone,
        sellersInvolved,
        items,
        itemCount,
        created,
        modified,
      ];
}
