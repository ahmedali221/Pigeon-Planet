import 'package:equatable/equatable.dart';

class CartItemModel extends Equatable {
  final int id;
  final int assetId;
  final String title;
  final int sellerId;
  final String sellerNickname;
  final int quantity;
  final double unitPrice;
  final double total;
  final DateTime? created;
  final DateTime? modified;

  const CartItemModel({
    required this.id,
    required this.assetId,
    required this.title,
    required this.sellerId,
    required this.sellerNickname,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.created,
    this.modified,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] as int,
        assetId: json['asset_id'] as int,
        title: json['title'] as String? ?? '',
        sellerId: json['seller_id'] as int,
        sellerNickname: json['seller_nickname'] as String? ?? '',
        quantity: json['quantity'] as int,
        unitPrice: double.tryParse(json['unit_price']?.toString() ?? '') ?? 0.0,
        total: double.tryParse(json['total']?.toString() ?? '') ?? 0.0,
        created: DateTime.tryParse(json['created'] as String? ?? ''),
        modified: DateTime.tryParse(json['modified'] as String? ?? ''),
      );

  @override
  List<Object?> get props =>
      [
        id,
        assetId,
        title,
        sellerId,
        sellerNickname,
        quantity,
        unitPrice,
        total,
        created,
        modified,
      ];
}
