import '../customer_home_summary.dart';
import '../seller_home_summary.dart';
import '../seller_model.dart';

abstract class SellerHomeRemoteDataSource {
  /// Returns null when the active profile is not a seller (HTTP 400).
  Future<SellerHomeSummary?> fetchHomeSummary();

  /// Returns null when the active profile is not a customer (HTTP 400).
  Future<CustomerHomeSummary?> fetchCustomerHomeSummary();

  /// Unread in-app notifications for the active profile mode.
  Future<int> fetchUnreadNotificationCount();

  /// Paginated list of seller profiles visible to the current user.
  Future<List<SellerModel>> fetchSellers({int page = 1});
}
