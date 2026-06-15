import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class PointTransactionModel {
  final int id;
  final String transactionType;
  final int points;
  final int balanceAfter;
  final String reason;
  final String created;

  const PointTransactionModel({
    required this.id,
    required this.transactionType,
    required this.points,
    required this.balanceAfter,
    required this.reason,
    required this.created,
  });

  factory PointTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointTransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      transactionType: json['transaction_type'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      created: json['created'] as String? ?? '',
    );
  }
}

class BadgeAwardModel {
  final int id;
  final String badgeType;
  final String name;
  final String description;
  final String awardedAt;
  final String iconUrl;

  const BadgeAwardModel({
    required this.id,
    required this.badgeType,
    required this.name,
    required this.description,
    required this.awardedAt,
    required this.iconUrl,
  });

  factory BadgeAwardModel.fromJson(Map<String, dynamic> json) {
    return BadgeAwardModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      badgeType: json['badge_type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      awardedAt: json['awarded_at'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
    );
  }
}

class LoyaltySnapshot {
  final int? balance;
  final int? loyaltyBalance;
  final int? packageBalance;
  final List<PointTransactionModel> transactions;
  final List<BadgeAwardModel> badges;

  const LoyaltySnapshot({
    required this.balance,
    required this.loyaltyBalance,
    required this.packageBalance,
    required this.transactions,
    required this.badges,
  });
}

abstract class PointsRemoteDataSource {
  /// Combined visible balance: loyalty bonuses + seller package points.
  Future<int?> fetchBalance();
  Future<int?> fetchLoyaltyBalance();
  Future<int?> fetchPackageBalance();
  Future<List<PointTransactionModel>> fetchTransactions();
  Future<List<BadgeAwardModel>> fetchMyBadges();
  Future<LoyaltySnapshot> fetchSnapshot();
}

class RealPointsRemoteDataSource implements PointsRemoteDataSource {
  final DioClient _dio;

  const RealPointsRemoteDataSource(this._dio);

  @override
  Future<int?> fetchBalance() async {
    final loyalty = await _safe<int?>(fetchLoyaltyBalance, null);
    final package = await _safe<int?>(fetchPackageBalance, null);
    if (loyalty == null && package == null) return null;
    return (loyalty ?? 0) + (package ?? 0);
  }

  @override
  Future<int?> fetchLoyaltyBalance() async {
    final response = await _dio.get(ApiConstants.corePoints);
    final data = response.data;
    if (data is Map && data['balance'] is num) {
      return (data['balance'] as num).toInt();
    }
    return null;
  }

  @override
  Future<int?> fetchPackageBalance() async {
    try {
      final response = await _dio.get(
        ApiConstants.mySellerPackages,
        queryParameters: {'active': 'true'},
      );
      final data = response.data;
      if (data is Map && data['remaining_points'] is num) {
        return (data['remaining_points'] as num).toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PointTransactionModel>> fetchTransactions() async {
    final response = await _dio.get(ApiConstants.corePointsHistory);
    return _readList(response.data)
        .map(
          (item) =>
              PointTransactionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<BadgeAwardModel>> fetchMyBadges() async {
    final response = await _dio.get(ApiConstants.loyaltyMyBadges);
    return _readList(response.data)
        .map((item) => BadgeAwardModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LoyaltySnapshot> fetchSnapshot() async {
    final results = await Future.wait<dynamic>([
      _safe<int?>(fetchLoyaltyBalance, null),
      _safe<int?>(fetchPackageBalance, null),
      _safe<List<PointTransactionModel>>(
        fetchTransactions,
        const <PointTransactionModel>[],
      ),
      _safe<List<BadgeAwardModel>>(fetchMyBadges, const <BadgeAwardModel>[]),
    ]);
    final loyaltyBalance = results[0] as int?;
    final packageBalance = results[1] as int?;
    return LoyaltySnapshot(
      balance: loyaltyBalance == null && packageBalance == null
          ? null
          : (loyaltyBalance ?? 0) + (packageBalance ?? 0),
      loyaltyBalance: loyaltyBalance,
      packageBalance: packageBalance,
      transactions: results[2] as List<PointTransactionModel>,
      badges: results[3] as List<BadgeAwardModel>,
    );
  }

  Future<T> _safe<T>(Future<T> Function() request, T fallback) async {
    try {
      return await request();
    } catch (_) {
      return fallback;
    }
  }

  List<dynamic> _readList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    return const [];
  }
}
