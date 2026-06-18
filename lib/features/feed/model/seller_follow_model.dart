import '../../home/model/seller_model.dart';

class SellerFollowModel {
  final int id;
  final SellerModel seller;
  final bool isActive;
  final DateTime? created;

  const SellerFollowModel({
    required this.id,
    required this.seller,
    required this.isActive,
    this.created,
  });

  factory SellerFollowModel.fromJson(Map<String, dynamic> json) {
    // SellerFollowingViewSet sends flat SellerFollowSellerSerializer objects
    // (not wrapped in {id, seller, is_active}) — treat the whole json as seller.
    return SellerFollowModel(
      id: json['id'] as int? ?? 0,
      seller: SellerModel.fromJson(json),
      isActive: json['is_followed'] as bool? ?? true,
      created: null,
    );
  }
}
