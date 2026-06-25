import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'asset_rating_model.dart';
import 'auction_item_model.dart';
import 'auction_model.dart';
import 'auction_create_payload.dart';
import 'auctions_repository.dart';
import 'bid_model.dart';
import 'bird_summary_model.dart';
import 'datasources/auctions_remote_datasource.dart';

class AuctionsRepositoryImpl implements AuctionsRepository {
  final AuctionsRemoteDataSource _dataSource;

  const AuctionsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AuctionPageResult>> getAuctions({int page = 1}) =>
      _wrap(() => _dataSource.getAuctions(page: page));

  @override
  Future<Either<Failure, List<AuctionModel>>> getActiveAuctions() =>
      _wrap(() => _dataSource.getActiveAuctions());

  @override
  Future<Either<Failure, List<AuctionModel>>> getEndingSoon(
          {int minutes = 60}) =>
      _wrap(() => _dataSource.getEndingSoon(minutes: minutes));

  @override
  Future<Either<Failure, List<AuctionModel>>> getMyAuctions({String? status}) =>
      _wrap(() => _dataSource.getMyAuctions(status: status));

  @override
  Future<Either<Failure, AuctionModel>> getAuctionDetail(int id) =>
      _wrap(() => _dataSource.getAuctionDetail(id));

  @override
  Future<Either<Failure, AuctionItemModel>> getAuctionItemDetail(int id) =>
      _wrap(() => _dataSource.getAuctionItemDetail(id));

  @override
  Future<Either<Failure, BidModel>> placeBid(int itemId, double amount) =>
      _wrap(() => _dataSource.placeBid(itemId, amount));

  @override
  Future<Either<Failure, List<BidModel>>> getBidsForItem(int itemId) =>
      _wrap(() => _dataSource.getBidsForItem(itemId));

  @override
  Future<Either<Failure, AuctionModel>> createAuction(AuctionCreatePayload payload) =>
      _wrap(() => _dataSource.createAuction(payload));

  @override
  Future<Either<Failure, void>> cancelAuction(int id) =>
      _wrap(() => _dataSource.cancelAuction(id));

  @override
  Future<Either<Failure, AuctionModel>> updateAuction(int id, {String? title, String? description, String? tags}) =>
      _wrap(() => _dataSource.updateAuction(id, title: title, description: description, tags: tags));

  @override
  Future<Either<Failure, void>> buyNow(int itemId) =>
      _wrap(() => _dataSource.buyNow(itemId));

  @override
  Future<Either<Failure, BidPageResult>> getMyBids({int page = 1}) =>
      _wrap(() => _dataSource.getMyBids(page: page));

  @override
  Future<Either<Failure, List<BirdSummaryModel>>> getSellerBirds({
    bool mineOnly = false,
    bool availableForAuction = false,
    bool? isMarketListed,
  }) =>
      _wrap(() => _dataSource.getSellerBirds(
            mineOnly: mineOnly,
            availableForAuction: availableForAuction,
            isMarketListed: isMarketListed,
          ));

  @override
  Future<Either<Failure, List<AssetRatingModel>>> getAssetRatings(int assetId) =>
      _wrap(() => _dataSource.getAssetRatings(assetId));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }
}
