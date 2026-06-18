import '../asset_rating_model.dart';
import '../auction_model.dart';
import '../bid_model.dart';
import '../auction_create_payload.dart';
import '../bird_summary_model.dart';

abstract class AuctionsRemoteDataSource {
  Future<List<AuctionModel>> getAuctions({int page = 1});
  Future<List<AuctionModel>> getActiveAuctions();
  Future<List<AuctionModel>> getEndingSoon({int minutes = 60});
  Future<List<AuctionModel>> getMyAuctions({String? status});
  Future<AuctionModel> getAuctionDetail(int id);
  Future<BidModel> placeBid(int itemId, double amount);
  Future<List<BidModel>> getBidsForItem(int itemId);
  Future<AuctionModel> createAuction(AuctionCreatePayload payload);
  Future<void> cancelAuction(int id);
  Future<AuctionModel> updateAuction(int id, {String? title, String? description, String? tags});
  Future<void> buyNow(int itemId);
  Future<List<BidModel>> getMyBids();
  Future<List<BirdSummaryModel>> getSellerBirds({
    bool mineOnly = false,
    bool availableForAuction = false,
  });
  Future<List<AssetRatingModel>> getAssetRatings(int assetId);
}
