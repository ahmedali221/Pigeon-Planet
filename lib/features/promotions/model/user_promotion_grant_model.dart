import 'package:equatable/equatable.dart';

class UserPromotionGrantModel extends Equatable {
  final int id;
  final int userId;
  final int? profileId;
  final String grantType;
  final int? discountOffer;
  final String? discountOfferTitle;
  final int? cashbackOffer;
  final String? cashbackOfferTitle;
  final String sourceType;
  final String? sourceId;
  final String status;
  final String? expiresAt;
  final String? redeemedAt;
  final int? orderItem;
  final String created;

  const UserPromotionGrantModel({
    required this.id,
    required this.userId,
    this.profileId,
    required this.grantType,
    this.discountOffer,
    this.discountOfferTitle,
    this.cashbackOffer,
    this.cashbackOfferTitle,
    required this.sourceType,
    this.sourceId,
    required this.status,
    this.expiresAt,
    this.redeemedAt,
    this.orderItem,
    required this.created,
  });

  factory UserPromotionGrantModel.fromJson(Map<String, dynamic> json) {
    return UserPromotionGrantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      profileId: (json['profile_id'] as num?)?.toInt(),
      grantType: json['grant_type'] as String? ?? '',
      discountOffer: (json['discount_offer'] as num?)?.toInt(),
      discountOfferTitle: json['discount_offer_title'] as String?,
      cashbackOffer: (json['cashback_offer'] as num?)?.toInt(),
      cashbackOfferTitle: json['cashback_offer_title'] as String?,
      sourceType: json['source_type'] as String? ?? '',
      sourceId: json['source_id'] as String?,
      status: json['status'] as String? ?? '',
      expiresAt: json['expires_at'] as String?,
      redeemedAt: json['redeemed_at'] as String?,
      orderItem: (json['order_item'] as num?)?.toInt(),
      created: json['created'] as String? ?? '',
    );
  }

  bool get isActive => status == 'active';
  bool get isRedeemed => status == 'redeemed';

  String get displayTitle {
    if (discountOfferTitle != null && discountOfferTitle!.isNotEmpty) {
      return discountOfferTitle!;
    }
    if (cashbackOfferTitle != null && cashbackOfferTitle!.isNotEmpty) {
      return cashbackOfferTitle!;
    }
    return grantType;
  }

  @override
  List<Object?> get props => [id, userId, grantType, status, sourceType];
}
