import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../auction_model.dart';
import '../bid_model.dart';
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
}
