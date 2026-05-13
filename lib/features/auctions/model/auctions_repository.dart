import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'auction_model.dart';
import 'bid_model.dart';

abstract class AuctionsRepository {
  Future<Either<Failure, List<AuctionModel>>> getAuctions({int page = 1});
  Future<Either<Failure, List<AuctionModel>>> getActiveAuctions();
  Future<Either<Failure, List<AuctionModel>>> getEndingSoon({int minutes = 60});
  Future<Either<Failure, List<AuctionModel>>> getMyAuctions();
  Future<Either<Failure, AuctionModel>> getAuctionDetail(int id);
  Future<Either<Failure, BidModel>> placeBid(int itemId, double amount);
  Future<Either<Failure, List<BidModel>>> getBidsForItem(int itemId);
}
