import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../lucky_wheel_current_model.dart';
import '../lucky_wheel_spin_history_model.dart';
import '../wheel_spin_result_model.dart';
import 'lucky_wheel_datasource.dart';

class RealLuckyWheelDataSource implements LuckyWheelDataSource {
  final DioClient _dio;

  RealLuckyWheelDataSource(this._dio);

  @override
  Future<LuckyWheelCurrentModel> fetchCurrent() async {
    try {
      final response = await _dio.get(ApiConstants.luckyWheelCurrent);
      return LuckyWheelCurrentModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل بيانات عجلة الحظ');
    }
  }

  @override
  Future<WheelSpinResultModel> spin({
    required String idempotencyKey,
    required List<int> segmentIds,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.luckyWheelSpin,
        data: {'idempotency_key': idempotencyKey},
      );
      final json = response.data as Map<String, dynamic>;
      final prize = (json['prize'] as Map<String, dynamic>?) ?? {};
      final prizeId = (prize['id'] as num?)?.toInt() ?? 0;
      final winnerIndex = _findWinnerIndex(prizeId, segmentIds);
      return WheelSpinResultModel.fromJson(json, winnerIndex: winnerIndex);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تدوير عجلة الحظ');
    }
  }

  @override
  Future<({List<LuckyWheelSpinHistoryModel> spins, bool hasMore})>
      fetchSpinHistory({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.luckyWheelMySpins,
        queryParameters: {'page': page},
      );
      final raw = response.data;
      final List<dynamic> list;
      final bool hasMore;
      if (raw is Map) {
        list = raw['results'] as List? ?? [];
        hasMore = raw['next'] != null;
      } else {
        list = raw as List? ?? [];
        hasMore = false;
      }
      return (
        spins: list
            .map((e) =>
                LuckyWheelSpinHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: hasMore,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('فشل تحميل سجل عجلة الحظ');
    }
  }

  int _findWinnerIndex(int prizeId, List<int> segmentIds) {
    final idx = segmentIds.indexOf(prizeId);
    return idx >= 0 ? idx : 0;
  }
}
