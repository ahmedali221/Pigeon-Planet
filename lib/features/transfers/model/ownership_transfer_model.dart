class TransferProfileModel {
  final int id;
  final String? nickname;
  final String? phone;
  final String type;

  const TransferProfileModel({
    required this.id,
    this.nickname,
    this.phone,
    required this.type,
  });

  String get displayName => nickname?.isNotEmpty == true
      ? nickname!
      : phone ?? 'غير معروف';

  factory TransferProfileModel.fromJson(Map<String, dynamic> json) {
    return TransferProfileModel(
      id: json['id'] as int,
      nickname: json['nickname'] as String?,
      phone: json['phone'] as String?,
      type: json['type'] as String? ?? '',
    );
  }
}

class OwnershipTransferModel {
  final int id;
  final int assetId;
  final String assetTitle;
  final TransferProfileModel? fromProfile;
  final TransferProfileModel toProfile;
  final String transferType; // direct | market | auction
  final String? note;
  final DateTime createdAt;

  const OwnershipTransferModel({
    required this.id,
    required this.assetId,
    required this.assetTitle,
    this.fromProfile,
    required this.toProfile,
    required this.transferType,
    this.note,
    required this.createdAt,
  });

  String get typeLabel => switch (transferType) {
        'direct' => 'تحويل مباشر',
        'market' => 'شراء من المتجر',
        'auction' => 'فوز في مزاد',
        _ => transferType,
      };

  bool get isDirect => transferType == 'direct';
  bool get isMarket => transferType == 'market';
  bool get isAuction => transferType == 'auction';

  factory OwnershipTransferModel.fromJson(Map<String, dynamic> json) {
    final from = json['from_profile'];
    final to = json['to_profile'];
    return OwnershipTransferModel(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      assetTitle: json['asset_title'] as String? ?? '',
      fromProfile: from != null
          ? TransferProfileModel.fromJson(from as Map<String, dynamic>)
          : null,
      toProfile:
          TransferProfileModel.fromJson(to as Map<String, dynamic>),
      transferType: json['transfer_type'] as String? ?? 'direct',
      note: (json['note'] as String?)?.isEmpty == true
          ? null
          : json['note'] as String?,
      createdAt: DateTime.parse(json['created'] as String),
    );
  }
}
