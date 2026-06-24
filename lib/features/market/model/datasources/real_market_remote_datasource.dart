import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../cashback_offer_model.dart';
import '../discount_offer_model.dart';
import '../market_feed_result.dart';
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
    String? ordering,
  }) async {
    final endpoint = _endpoints[assetType];
    if (endpoint == null) return [];

    final params = <String, dynamic>{
      'is_market_listed': 'true',
      'page': page,
      if (query != null && query.isNotEmpty) 'q': query,
      'ordering': ?ordering,
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
  Future<MarketFeedResult> getFeedMarket({String? cursor}) async {
    final params = <String, dynamic>{'cursor': ?cursor};

    final response = await _dio.get(
      ApiConstants.feedMarket,
      queryParameters: params.isEmpty ? null : params,
    );
    final data = response.data as Map<String, dynamic>;

    final results = data['results'] as List<dynamic>? ?? [];
    final nextCursor = data['next_cursor'] as String?;

    final products = results.map((e) {
      final json = e as Map<String, dynamic>;
      final item = Map<String, dynamic>.from(
        json['item'] as Map<String, dynamic>? ?? json,
      );
      item['source'] ??= json['source'];
      final rawType =
          item['asset_type'] as String? ?? item['category'] as String? ?? 'supply';
      final categoryId = _mapAssetType(rawType);
      return ProductModel.fromJson(item, categoryId);
    }).toList();

    return MarketFeedResult(products: products, nextCursor: nextCursor);
  }

  @override
  Future<List<DiscountOfferModel>> getDiscountOffers() async {
    final response = await _dio.get(ApiConstants.currentDiscountOffers);
    final data = response.data;

    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items
        .map((e) => DiscountOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CashbackOfferModel>> getCashbackOffers() async {
    final response = await _dio.get(ApiConstants.currentCashbackOffers);
    final data = response.data;

    List<dynamic> items;
    if (data is Map && data.containsKey('results')) {
      items = data['results'] as List<dynamic>? ?? [];
    } else if (data is List) {
      items = data;
    } else {
      return [];
    }
    return items
        .map((e) => CashbackOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String _mapAssetType(String raw) => switch (raw) {
        'supply' => 'supplies',
        'accessory' => 'accessories',
        'feed' => 'feeds',
        'supplement' => 'supplements',
        _ => raw,
      };
}
