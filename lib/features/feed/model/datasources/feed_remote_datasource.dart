import '../../../home/model/seller_model.dart';
import '../seller_block_model.dart';
import '../seller_follow_model.dart';
import '../feed_auction_item_model.dart';

abstract class FeedRemoteDataSource {
  Future<void> followSeller(int sellerId);
  Future<void> unfollowSeller(int sellerId);
  Future<List<SellerFollowModel>> getFollowing();
  Future<List<SellerModel>> getSuggestions();
  Future<List<SellerBlockModel>> getBlocks();
  Future<void> blockProfile(int profileId);
  Future<void> unblockProfile(int profileId);
  Future<FeedAuctionResult> getAuctionFeed({String? cursor});
}
