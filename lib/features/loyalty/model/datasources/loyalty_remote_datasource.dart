import '../badge_model.dart';

abstract class LoyaltyRemoteDataSource {
  Future<List<BadgeModel>> fetchMyBadges();
}
