import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../asset_rating_model.dart';
import '../auction_model.dart';
import '../auction_create_payload.dart';
import '../bid_model.dart';
import '../bird_summary_model.dart';
import 'auctions_remote_datasource.dart';

class RealAuctionsRemoteDataSource implements AuctionsRemoteDataSource {
  final DioClient _dio;

  const RealAuctionsRemoteDataSource(this._dio);

  List<AuctionModel> _parseList(dynamic data) {
    if (data == null) return [];
    List<dynamic> items;
    if (data is Map) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items
        .map((j) => AuctionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AuctionModel>> getAuctions({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.auctions,
      queryParameters: {'page': page},
    );
    return _parseList(response.data);
  }

  @override
  Future<List<AuctionModel>> getActiveAuctions() async {
    final response = await _dio.get(ApiConstants.auctionsActive);
    return _parseList(response.data);
  }

  @override
  Future<List<AuctionModel>> getEndingSoon({int minutes = 60}) async {
    final response = await _dio.get(
      ApiConstants.auctionsEndingSoon,
      queryParameters: {'minutes': minutes},
    );
    return _parseList(response.data);
  }

  @override
  Future<List<AuctionModel>> getMyAuctions() async {
    final response = await _dio.get(ApiConstants.auctionsMyAuctions);
    return _parseList(response.data);
  }

  @override
  Future<AuctionModel> getAuctionDetail(int id) async {
    final response = await _dio.get(ApiConstants.auctionDetail(id));
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BidModel> placeBid(int itemId, double amount) async {
    final response = await _dio.post(
      ApiConstants.placeBid(itemId),
      data: {'amount': amount.toStringAsFixed(2)},
    );
    return BidModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BidModel>> getBidsForItem(int itemId) async {
    final response = await _dio.get(
      ApiConstants.bids,
      queryParameters: {'item_id': itemId},
    );
    final data = response.data;
    if (data == null) return [];
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((j) => BidModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuctionModel> createAuction(AuctionCreatePayload payload) async {
    var finalPayload = payload;
    // Upload the cover image to Cloudinary first (mirrors bird image upload),
    // then send the resulting URL with the auction creation request.
    if ((payload.thumbnailUrl == null || payload.thumbnailUrl!.isEmpty) &&
        payload.thumbnailPath != null &&
        payload.thumbnailPath!.isNotEmpty) {
      final url = await CloudinaryService.uploadAuctionThumbnail(
        payload.thumbnailPath!,
        payload.title,
      );
      if (url != null && url.isNotEmpty) {
        finalPayload = payload.copyWith(thumbnailUrl: url);
      }
    }
    final response = await _dio.post(
      ApiConstants.createAuction,
      data: finalPayload.toJson(),
    );
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BirdSummaryModel>> getSellerBirds({
    bool mineOnly = false,
    bool availableForAuction = false,
  }) async {
    final Map<String, String> params = {};
    if (mineOnly) params['mine'] = 'true';
    if (availableForAuction) params['available_for_auction'] = 'true';
    final response = await _dio.get(
      ApiConstants.birds,
      queryParameters: params.isEmpty ? null : params,
    );
    final data = response.data;
    if (data == null) return [];
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((j) => BirdSummaryModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AssetRatingModel>> getAssetRatings(int assetId) async {
    final response = await _dio.get(
      ApiConstants.assetRatings,
      queryParameters: {'asset_id': assetId},
    );
    final data = response.data;
    if (data == null) return [];
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : []);
    return items
        .map((j) => AssetRatingModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
