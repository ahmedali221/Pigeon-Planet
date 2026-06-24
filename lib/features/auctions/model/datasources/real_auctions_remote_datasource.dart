import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../asset_rating_model.dart';
import '../auction_item_model.dart';
import '../auction_model.dart';
import '../auction_create_payload.dart';
import '../bid_model.dart';
import '../bird_summary_model.dart';
import 'auctions_remote_datasource.dart';

class RealAuctionsRemoteDataSource implements AuctionsRemoteDataSource {
  final DioClient _dio;

  const RealAuctionsRemoteDataSource(this._dio);

  ({List<T> items, bool hasMore}) _parsePage<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return (items: <T>[], hasMore: false);
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data is List ? data : <dynamic>[]);
    return (
      items: items.map((j) => fromJson(j as Map<String, dynamic>)).toList(),
      hasMore: data is Map && data['next'] != null,
    );
  }

  List<AuctionModel> _parseList(dynamic data) {
    return _parsePage(data, AuctionModel.fromJson).items;
  }

  @override
  Future<AuctionPageResult> getAuctions({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.auctions,
      queryParameters: {'page': page},
    );
    return _parsePage(response.data, AuctionModel.fromJson);
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
  Future<List<AuctionModel>> getMyAuctions({String? status}) async {
    final response = await _dio.get(
      ApiConstants.auctionsMyAuctions,
      queryParameters: status != null ? {'status': status} : null,
    );
    return _parseList(response.data);
  }

  @override
  Future<AuctionModel> getAuctionDetail(int id) async {
    final response = await _dio.get(ApiConstants.auctionDetail(id));
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuctionItemModel> getAuctionItemDetail(int id) async {
    final response = await _dio.get(ApiConstants.auctionItemDetail(id));
    return AuctionItemModel.fromJson(response.data as Map<String, dynamic>);
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
    final response = await _dio.post(
      ApiConstants.auctions,
      data: payload.toJson(),
    );
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> cancelAuction(int id) async {
    await _dio.post(ApiConstants.auctionCancel(id), data: {});
  }

  @override
  Future<AuctionModel> updateAuction(int id, {String? title, String? description, String? tags}) async {
    final data = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
    };
    final response = await _dio.patch(ApiConstants.auctionDetail(id), data: data);
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> buyNow(int itemId) async {
    await _dio.post(ApiConstants.buyNow(itemId), data: {});
  }

  @override
  Future<BidPageResult> getMyBids({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.myBids,
      queryParameters: {'page': page},
    );
    return _parsePage(response.data, BidModel.fromJson);
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
