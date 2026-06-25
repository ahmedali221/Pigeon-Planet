import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import 'electronic_clock_model.dart';

abstract class ClocksRepository {
  Future<Either<Failure, List<ElectronicClockModel>>> getClocks({
    String? search,
    bool inStockOnly,
  });
  Future<Either<Failure, ElectronicClockModel>> getClockDetail(int id);
  Future<Either<Failure, ClockOrderModel>> placeOrder({
    required int clockId,
    required int quantity,
    String note,
  });
  Future<Either<Failure, ClockOrderModel>> submitPaymentProof({
    required int orderId,
    required String proofUrl,
    String note,
  });
  Future<Either<Failure, List<ClockOrderModel>>> getMyOrders();
}
