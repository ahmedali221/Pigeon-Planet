import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../cashback_transaction_model.dart';
import 'promotions_remote_datasource.dart';

class RealPromotionsRemoteDataSource implements PromotionsRemoteDataSource {
  final DioClient _dio;

  RealPromotionsRemoteDataSource(this._dio);

  @override
  Future<List<CashbackTransactionModel>> fetchCashbackTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.cashbackTransactions);
      final data = response.data;
      final list = data is List
          ? data
          : (data is Map ? (data['results'] as List? ?? []) : []);
      return list
          .map((e) =>
              CashbackTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('فشل تحميل سجل الكاش باك');
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
    } catch (e) {
      throw ApiException('فشل تحميل رصيد الكاش باك');
    }
  }
}
