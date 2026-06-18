class PackageModel {
  final int id;
  final String name;
  final String description;
  final int points;
  final String price;
  final int activationPeriodDays;
  final int auctionCost;
  final int productCost;
  final bool isAvailable;

  const PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.price,
    required this.activationPeriodDays,
    required this.auctionCost,
    required this.productCost,
    required this.isAvailable,
  });

  factory PackageModel.fromJson(Map<String, dynamic> j) => PackageModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        description: (j['description'] as String?)?.trim() ?? '',
        points: (j['points'] as num?)?.toInt() ?? 0,
        price: j['price']?.toString() ?? '0',
        activationPeriodDays: (j['activation_period_days'] as num?)?.toInt() ?? 0,
        auctionCost: (j['auction_cost'] as num?)?.toInt() ?? 0,
        productCost: (j['product_cost'] as num?)?.toInt() ?? 0,
        isAvailable: j['is_available'] as bool? ?? true,
      );
}

class ActiveSellerPackageModel {
  final int id;
  final PackageModel package;
  final int remainingPoints;
  final DateTime? expiresAt;
  final int auctionCost;
  final int productCost;

  const ActiveSellerPackageModel({
    required this.id,
    required this.package,
    required this.remainingPoints,
    this.expiresAt,
    required this.auctionCost,
    required this.productCost,
  });

  factory ActiveSellerPackageModel.fromJson(Map<String, dynamic> j) =>
      ActiveSellerPackageModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        package: PackageModel.fromJson(
          Map<String, dynamic>.from(j['package'] as Map? ?? {}),
        ),
        remainingPoints: (j['remaining_points'] as num?)?.toInt() ?? 0,
        expiresAt: j['expires_at'] != null
            ? DateTime.tryParse(j['expires_at'] as String)
            : null,
        auctionCost: (j['auction_cost'] as num?)?.toInt() ?? 0,
        productCost: (j['product_cost'] as num?)?.toInt() ?? 0,
      );

  bool get hasEnoughForAuction => remainingPoints >= auctionCost;
  bool get hasEnoughForProduct => remainingPoints >= productCost;
}

class PendingSellerPackageModel {
  final int id;
  final String packageName;
  final String status;
  final String createdAt;

  const PendingSellerPackageModel({
    required this.id,
    required this.packageName,
    required this.status,
    required this.createdAt,
  });

  factory PendingSellerPackageModel.fromJson(Map<String, dynamic> j) =>
      PendingSellerPackageModel(
        id: (j['id'] as num?)?.toInt() ?? 0,
        packageName:
            (j['package'] as Map?)?['name'] as String? ?? '',
        status: j['status'] as String? ?? '',
        createdAt: j['created_at'] as String? ?? '',
      );
}
