import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'asset_rating_model.dart';
import 'auction_model.dart';
import 'auction_create_payload.dart';
import 'bid_model.dart';
import 'bird_summary_model.dart';

abstract class AuctionsRepository {
  Future<Either<Failure, List<AuctionModel>>> getAuctions({int page = 1});
  Future<Either<Failure, List<AuctionModel>>> getActiveAuctions();
  Future<Either<Failure, List<AuctionModel>>> getEndingSoon({int minutes = 60});
  Future<Either<Failure, List<AuctionModel>>> getMyAuctions();
  Future<Either<Failure, AuctionModel>> getAuctionDetail(int id);
  Future<Either<Failure, BidModel>> placeBid(int itemId, double amount);
  Future<Either<Failure, List<BidModel>>> getBidsForItem(int itemId);
  Future<Either<Failure, AuctionModel>> createAuction(AuctionCreatePayload payload);
  Future<Either<Failure, List<BirdSummaryModel>>> getSellerBirds({
    bool mineOnly = false,
    bool availableForAuction = false,
  });
  Future<Either<Failure, List<AssetRatingModel>>> getAssetRatings(int assetId);
}
