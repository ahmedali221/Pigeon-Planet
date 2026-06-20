import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/model/seller_model.dart';
import '../feed_auction_item_model.dart';
import '../seller_block_model.dart';
import '../seller_follow_model.dart';
import 'feed_remote_datasource.dart';

export 'feed_remote_datasource.dart' show SellerListResult;

class RealFeedRemoteDataSource implements FeedRemoteDataSource {
  final DioClient _dio;

  const RealFeedRemoteDataSource(this._dio);

  @override
  Future<void> followSeller(int sellerId) async {
    try {
      await _dio.post(ApiConstants.followSeller(sellerId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل في متابعة البائع');
    }
  }

  @override
  Future<void> unfollowSeller(int sellerId) async {
    try {
      await _dio.post(ApiConstants.unfollowSeller(sellerId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل في إلغاء المتابعة');
    }
  }

  @override
  Future<List<SellerFollowModel>> getFollowing() async {
    try {
      final response = await _dio.get(ApiConstants.following);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => SellerFollowModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل قائمة المتابعين');
    }
  }

  @override
  Future<List<SellerModel>> getSuggestions() async {
    try {
      final response = await _dio.get(
        ApiConstants.peopleYouMayKnow,
        queryParameters: {'limit': 20},
      );
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل اقتراحات البائعين');
    }
  }

  @override
  Future<List<SellerBlockModel>> getBlocks() async {
    try {
      final response = await _dio.get(ApiConstants.blocks);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) => SellerBlockModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل قائمة المحظورين');
    }
  }

  @override
  Future<void> blockProfile(int profileId) async {
    try {
      await _dio.post(ApiConstants.blocks, data: {'profile_id': profileId});
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل في حظر الملف الشخصي');
    }
  }

  @override
  Future<void> unblockProfile(int profileId) async {
    try {
      await _dio.delete(ApiConstants.unblock(profileId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل في إلغاء الحظر');
    }
  }

  @override
  Future<SellerListResult> getSellersList(int page) async {
    try {
      final response = await _dio.get(
        ApiConstants.feedSellersList,
        queryParameters: {'page': page, 'page_size': 20},
      );
      final data = response.data as Map<String, dynamic>;
      final list = (data['results'] as List<dynamic>? ?? []);
      return SellerListResult(
        sellers: list
            .map((e) => SellerModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        count: data['count'] as int? ?? 0,
        hasMore: data['has_more'] as bool? ?? false,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل قائمة المربّين');
    }
  }

  @override
  Future<FeedAuctionResult> getAuctionFeed({String? cursor}) async {
    try {
      final params = <String, dynamic>{'cursor': ?cursor};
      final response = await _dio.get(
        ApiConstants.feedAuctions,
        queryParameters: params.isEmpty ? null : params,
      );
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];
      final nextCursor = data['next_cursor'] as String?;
      final items = results
          .map((e) =>
              FeedAuctionItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return FeedAuctionResult(items: items, nextCursor: nextCursor);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل مزادات المتابعين');
    }
  }
}
