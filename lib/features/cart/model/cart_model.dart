import 'package:equatable/equatable.dart';

import 'cart_item_model.dart';

class CartModel extends Equatable {
  final int id;
  final String status;
  final List<CartItemModel> items;
  final double subtotal;
  final int itemsCount;
  final DateTime? created;
  final DateTime? modified;

  const CartModel({
    required this.id,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.itemsCount,
    this.created,
    this.modified,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: json['id'] as int,
        status: json['status'] as String? ?? 'active',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal:
            double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
        itemsCount: json['items_count'] as int? ?? 0,
        created: DateTime.tryParse(json['created'] as String? ?? ''),
        modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      );

  @override
  List<Object?> get props =>
      [id, status, items, subtotal, itemsCount, created, modified];
}
