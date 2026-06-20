import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../home/model/seller_model.dart';
import 'datasources/feed_remote_datasource.dart';
import 'feed_auction_item_model.dart';
import 'seller_block_model.dart';
import 'seller_follow_model.dart';

abstract class FeedRepository {
  Future<Either<Failure, void>> followSeller(int sellerId);
  Future<Either<Failure, void>> unfollowSeller(int sellerId);
  Future<Either<Failure, List<SellerFollowModel>>> getFollowing();
  Future<Either<Failure, List<SellerModel>>> getSuggestions();
  Future<Either<Failure, List<SellerBlockModel>>> getBlocks();
  Future<Either<Failure, void>> blockProfile(int profileId);
  Future<Either<Failure, void>> unblockProfile(int profileId);
  Future<Either<Failure, FeedAuctionResult>> getAuctionFeed({String? cursor});
  Future<Either<Failure, SellerListResult>> getSellersList(int page);
}
