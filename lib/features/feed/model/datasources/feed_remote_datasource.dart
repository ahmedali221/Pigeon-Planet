import '../../../home/model/seller_model.dart';
import '../seller_block_model.dart';
import '../seller_follow_model.dart';
import '../seller_package_follow_model.dart';
import '../feed_auction_item_model.dart';

class SellerListResult {
  final List<SellerModel> sellers;
  final int count;
  final bool hasMore;

  const SellerListResult({
    required this.sellers,
    required this.count,
    required this.hasMore,
  });
}

abstract class FeedRemoteDataSource {
  Future<void> followSeller(int sellerId);
  Future<void> unfollowSeller(int sellerId);
  Future<List<SellerFollowModel>> getFollowing();
  Future<void> followSellerPackage(int packageId);
  Future<void> unfollowSellerPackage(int packageId);
  Future<List<SellerPackageFollowModel>> getFollowingPackages();
  Future<List<SellerModel>> getSuggestions();
  Future<List<SellerBlockModel>> getBlocks();
  Future<void> blockProfile(int profileId);
  Future<void> unblockProfile(int profileId);
  Future<FeedAuctionResult> getAuctionFeed({String? cursor});
  Future<SellerListResult> getSellersList(int page);
}
