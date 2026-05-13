import '../seller_home_summary.dart';

abstract class SellerHomeRemoteDataSource {
  /// Returns null when the active profile is not a seller (HTTP 400).
  Future<SellerHomeSummary?> fetchHomeSummary();
}
