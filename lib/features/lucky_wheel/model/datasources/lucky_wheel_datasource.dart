import '../lucky_wheel_current_model.dart';
import '../lucky_wheel_spin_history_model.dart';
import '../wheel_spin_result_model.dart';

abstract class LuckyWheelDataSource {
  Future<LuckyWheelCurrentModel> fetchCurrent();

  Future<WheelSpinResultModel> spin({
    required String idempotencyKey,
    required List<int> segmentIds,
  });

  Future<({List<LuckyWheelSpinHistoryModel> spins, bool hasMore})>
      fetchSpinHistory({int page = 1});
}
