import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../comment_model.dart';
import '../rating_model.dart';
import 'ratings_remote_datasource.dart';

class RealRatingsRemoteDataSource implements RatingsRemoteDataSource {
  final DioClient _dio;

  const RealRatingsRemoteDataSource(this._dio);

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data == null) return [];
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data as List<dynamic>? ?? []);
    return items.map((j) => fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<RatingModel>> getAssetRatings(int assetId) async {
    final response = await _dio.get(
      ApiConstants.assetRatings,
      queryParameters: {'asset_id': assetId},
    );
    return _parseList(response.data, RatingModel.fromJson);
  }

  @override
  Future<void> createAssetRating({
    required int assetId,
    required int stars,
    String? commentText,
  }) async {
    final data = <String, dynamic>{
      'asset': {'id': assetId},
      'stars': stars,
      if (commentText != null && commentText.isNotEmpty)
        'comment': {'text': commentText},
    };
    await _dio.post(ApiConstants.assetRatings, data: data);
  }

  @override
  Future<List<RatingModel>> getSellerRatings(int sellerId) async {
    final response = await _dio.get(
      ApiConstants.sellerRatings,
      queryParameters: {'seller_id': sellerId},
    );
    return _parseList(response.data, RatingModel.fromJson);
  }

  @override
  Future<void> createSellerRating({
    required int sellerId,
    required int stars,
    String? commentText,
  }) async {
    final data = <String, dynamic>{
      'seller': {'id': sellerId},
      'stars': stars,
      if (commentText != null && commentText.isNotEmpty)
        'comment': {'text': commentText},
    };
    await _dio.post(ApiConstants.sellerRatings, data: data);
  }

  @override
  Future<List<CommentModel>> getAssetComments(int assetId) async {
    final response = await _dio.get(
      ApiConstants.assetComments,
      queryParameters: {'asset_id': assetId},
    );
    return _parseList(response.data, CommentModel.fromJson);
  }

  @override
  Future<void> createAssetComment({
    required int assetId,
    required String text,
  }) async {
    await _dio.post(ApiConstants.assetComments, data: {
      'asset': {'id': assetId},
      'text': text,
    });
  }

  @override
  Future<List<CommentModel>> getSellerComments(int sellerId) async {
    final response = await _dio.get(
      ApiConstants.sellerComments,
      queryParameters: {'seller_id': sellerId},
    );
    return _parseList(response.data, CommentModel.fromJson);
  }

  @override
  Future<void> createSellerComment({
    required int sellerId,
    required String text,
  }) async {
    await _dio.post(ApiConstants.sellerComments, data: {
      'seller': {'id': sellerId},
      'text': text,
    });
  }
}
