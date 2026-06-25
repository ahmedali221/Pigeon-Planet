import '../electronic_clock_model.dart';

abstract class ClocksRemoteDataSource {
  Future<List<ElectronicClockModel>> getClocks({String? search, bool inStockOnly});
  Future<ElectronicClockModel> getClockDetail(int id);
  Future<ClockOrderModel> placeOrder({
    required int clockId,
    required int quantity,
    String note,
  });
  Future<ClockOrderModel> submitPaymentProof({
    required int orderId,
    required String proofUrl,
    String note,
  });
  Future<List<ClockOrderModel>> getMyOrders();
}
