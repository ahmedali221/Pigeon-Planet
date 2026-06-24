import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../cashback_offer_model.dart';
import '../cashback_transaction_model.dart';
import '../discount_offer_model.dart';
import '../user_promotion_grant_model.dart';
import 'promotions_remote_datasource.dart';

class RealPromotionsRemoteDataSource implements PromotionsRemoteDataSource {
  final DioClient _dio;

  RealPromotionsRemoteDataSource(this._dio);

  List<T> _extractList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final list = data is List ? data : (data is Map ? (data['results'] as List? ?? []) : []);
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  bool _hasMore(dynamic data) {
    if (data is Map) return data['next'] != null;
    return false;
  }

  @override
  Future<List<DiscountOfferModel>> fetchDiscountOffers() async {
    try {
      final response = await _dio.get(ApiConstants.currentDiscountOffers);
      return _extractList(response.data, DiscountOfferModel.fromJson);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل العروض');
    }
  }

  @override
  Future<List<CashbackOfferModel>> fetchCashbackOffers() async {
    try {
      final response = await _dio.get(ApiConstants.currentCashbackOffers);
      return _extractList(response.data, CashbackOfferModel.fromJson);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل عروض الكاش باك');
    }
  }

  @override
  Future<double> fetchCashbackBalance() async {
    try {
      final response = await _dio.get(ApiConstants.cashbackBalance);
      final data = response.data;
      if (data is Map) {
        return double.tryParse(
                data['cashback_balance']?.toString() ??
                    data['balance']?.toString() ??
                    '0') ??
            0.0;
      }
      return 0.0;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل رصيد الكاش باك');
    }
  }

  @override
  Future<({List<CashbackTransactionModel> items, bool hasMore})>
      fetchCashbackTransactions({int page = 1}) async {
    try {
      final response = await _dio
          .get(ApiConstants.cashbackTransactions, queryParameters: {'page': page});
      final data = response.data;
      return (
        items: _extractList(data, CashbackTransactionModel.fromJson),
        hasMore: _hasMore(data),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل سجل الكاش باك');
    }
  }

  @override
  Future<({List<UserPromotionGrantModel> items, bool hasMore})> fetchMyGrants(
      {int page = 1}) async {
    try {
      final response = await _dio
          .get(ApiConstants.myPromotionGrants, queryParameters: {'page': page});
      final data = response.data;
      return (
        items: _extractList(data, UserPromotionGrantModel.fromJson),
        hasMore: _hasMore(data),
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل العروض الخاصة');
    }
  }
}
