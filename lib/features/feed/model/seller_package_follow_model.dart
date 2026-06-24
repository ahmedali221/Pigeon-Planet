class SellerPackageFollowModel {
  final int id;
  final int packageId;
  final String packageName;
  final int? sellerId;
  final String sellerNickname;

  const SellerPackageFollowModel({
    required this.id,
    required this.packageId,
    required this.packageName,
    this.sellerId,
    this.sellerNickname = '',
  });

  factory SellerPackageFollowModel.fromJson(Map<String, dynamic> json) {
    final pkg = json['seller_package'] as Map<String, dynamic>? ?? json;
    final seller = pkg['seller'] as Map<String, dynamic>?;
    return SellerPackageFollowModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      packageId: (pkg['id'] as num?)?.toInt() ?? 0,
      packageName: pkg['display_name'] as String? ??
          pkg['name'] as String? ??
          '',
      sellerId: (seller?['id'] as num?)?.toInt(),
      sellerNickname: seller?['nickname'] as String? ?? '',
    );
  }
}
