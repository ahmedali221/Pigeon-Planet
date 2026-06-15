import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../features/auctions/model/bird_summary_model.dart';
import '../product_model.dart';
import 'market_remote_datasource.dart';

class RealMarketRemoteDataSource implements MarketRemoteDataSource {
  final DioClient _dio;

  const RealMarketRemoteDataSource(this._dio);

  static const _endpoints = {
    'supplies': ApiConstants.supplies,
    'accessories': ApiConstants.accessories,
    'feeds': ApiConstants.feeds,
    'supplements': ApiConstants.supplements,
    'birds': ApiConstants.birds,
  };

  @override
  Future<List<ProductModel>> getProducts(
    String assetType, {
    int page = 1,
    String? query,
  }) async {
    final endpoint = _endpoints[assetType];
    if (endpoint == null) return [];

    final params = <String, dynamic>{
      'is_market_listed': 'true',
      'page': page,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final response = await _dio.get(endpoint, queryParameters: params);
    final data = response.data;

    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }

    return items
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>, assetType))
        .toList();
  }

  @override
  Future<List<BirdSummaryModel>> getBirds({
    int page = 1,
    String? query,
  }) async {
    final params = <String, dynamic>{
      'is_market_listed': 'true',
      'page': page,
      if (query != null && query.isNotEmpty) 'q': query,
    };

    final response = await _dio.get(ApiConstants.birds, queryParameters: params);
    final data = response.data;

    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      throw const ServerException('Unexpected response format');
    }

    return items
        .map((e) => BirdSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

}
