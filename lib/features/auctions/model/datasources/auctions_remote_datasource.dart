import '../auction_model.dart';
import '../bid_model.dart';

abstract class AuctionsRemoteDataSource {
  Future<List<AuctionModel>> getAuctions({int page = 1});
  Future<List<AuctionModel>> getActiveAuctions();
  Future<List<AuctionModel>> getEndingSoon({int minutes = 60});
  Future<List<AuctionModel>> getMyAuctions();
  Future<AuctionModel> getAuctionDetail(int id);
  Future<BidModel> placeBid(int itemId, double amount);
  Future<List<BidModel>> getBidsForItem(int itemId);
}
