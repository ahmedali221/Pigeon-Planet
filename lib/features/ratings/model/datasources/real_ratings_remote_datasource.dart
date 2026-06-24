import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../comment_model.dart';
import '../rating_model.dart';
import 'ratings_remote_datasource.dart';

class RealRatingsRemoteDataSource implements RatingsRemoteDataSource {
  final DioClient _dio;

  const RealRatingsRemoteDataSource(this._dio);

  ({List<T> items, bool hasMore}) _parsePage<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data == null) return (items: <T>[], hasMore: false);
    var hasMore = false;
    final items = data is Map
        ? (data['results'] as List<dynamic>? ?? [])
        : (data as List<dynamic>? ?? []);
    if (data is Map) {
      hasMore = data['next'] != null;
    }
    return (
      items: items.map((j) => fromJson(j as Map<String, dynamic>)).toList(),
      hasMore: hasMore,
    );
  }

  @override
  Future<RatingPageResult> getAssetRatings(int assetId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.assetRatings,
      queryParameters: {'asset_id': assetId, 'page': page},
    );
    return _parsePage(response.data, RatingModel.fromJson);
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
  Future<RatingPageResult> getSellerRatings(int sellerId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.sellerRatings,
      queryParameters: {'seller_id': sellerId, 'page': page},
    );
    return _parsePage(response.data, RatingModel.fromJson);
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
  Future<CommentPageResult> getAssetComments(int assetId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.assetComments,
      queryParameters: {'asset_id': assetId, 'page': page},
    );
    return _parsePage(response.data, CommentModel.fromJson);
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
  Future<CommentPageResult> getSellerComments(int sellerId, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.sellerComments,
      queryParameters: {'seller_id': sellerId, 'page': page},
    );
    return _parsePage(response.data, CommentModel.fromJson);
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
