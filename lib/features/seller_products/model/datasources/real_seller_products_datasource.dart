import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../seller_product_model.dart';
import 'seller_products_datasource.dart';

class RealSellerProductsDataSource implements SellerProductsDataSource {
  final DioClient _dio;

  const RealSellerProductsDataSource(this._dio);

  static const _categoryEndpoints = {
    'supplies': ApiConstants.supplies,
    'accessories': ApiConstants.accessories,
    'feeds': ApiConstants.feeds,
    'supplements': ApiConstants.supplements,
  };

  @override
  Future<int> getSellerProfileId() async {
    final response = await _dio.get(ApiConstants.mySellers);
    final data = response.data;

    if (data is Map && data.containsKey('results')) {
      final results = data['results'] as List<dynamic>;
      if (results.isNotEmpty) {
        return (results.first as Map<String, dynamic>)['id'] as int;
      }
    } else if (data is List && data.isNotEmpty) {
      return (data.first as Map<String, dynamic>)['id'] as int;
    } else if (data is Map && data.containsKey('id')) {
      return data['id'] as int;
    }
    throw const ServerException('Could not resolve seller profile');
  }

  @override
  Future<List<SellerProductModel>> getProducts({
    required int profileId,
    String? category,
    int page = 1,
  }) async {
    final categories =
        category != null ? [category] : _categoryEndpoints.keys.toList();
    final results = <SellerProductModel>[];

    for (final cat in categories) {
      final endpoint = _categoryEndpoints[cat];
      if (endpoint == null) continue;

      final response = await _dio.get(endpoint, queryParameters: {
        'owner': profileId,
        'page': page,
      });

      final data = response.data;
      List<dynamic> items;
      if (data is Map && data.containsKey('results')) {
        items = data['results'] as List<dynamic>? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        continue;
      }

      results.addAll(items
          .whereType<Map<String, dynamic>>()
          .map((e) => SellerProductModel.fromJson(e, cat)));
    }

    return results;
  }

  @override
  Future<SellerProductModel> createProduct(
      String category, Map<String, dynamic> data) async {
    final endpoint = _categoryEndpoints[category];
    if (endpoint == null) throw ServerException('Unknown category: $category');
    final response = await _dio.post(endpoint, data: data);
    return SellerProductModel.fromJson(
        response.data as Map<String, dynamic>, category);
  }

  @override
  Future<SellerProductModel> updateProduct(
      String category, int id, Map<String, dynamic> data) async {
    final response =
        await _dio.patch('/assets/$category/$id/', data: data);
    return SellerProductModel.fromJson(
        response.data as Map<String, dynamic>, category);
  }

  @override
  Future<void> deleteProduct(String category, int id) async {
    await _dio.delete('/assets/$category/$id/');
  }
}
