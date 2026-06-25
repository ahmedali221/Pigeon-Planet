import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'clocks_repository.dart';
import 'datasources/clocks_remote_datasource.dart';
import 'electronic_clock_model.dart';

class ClocksRepositoryImpl implements ClocksRepository {
  final ClocksRemoteDataSource _dataSource;

  ClocksRepositoryImpl(this._dataSource);

  Failure _mapFailure(ApiException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is ForbiddenException) return ForbiddenFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }

  Failure _handleError(Object e) {
    if (e is DioException) {
      final inner = e.error;
      if (inner is ApiException) return _mapFailure(inner);
    }
    return const ServerFailure();
  }

  @override
  Future<Either<Failure, List<ElectronicClockModel>>> getClocks({
    String? search,
    bool inStockOnly = false,
  }) async {
    try {
      final result = await _dataSource.getClocks(
          search: search, inStockOnly: inStockOnly);
      return Right(result);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ElectronicClockModel>> getClockDetail(int id) async {
    try {
      return Right(await _dataSource.getClockDetail(id));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ClockOrderModel>> placeOrder({
    required int clockId,
    required int quantity,
    String note = '',
  }) async {
    try {
      return Right(await _dataSource.placeOrder(
          clockId: clockId, quantity: quantity, note: note));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, ClockOrderModel>> submitPaymentProof({
    required int orderId,
    required String proofUrl,
    String note = '',
  }) async {
    try {
      return Right(await _dataSource.submitPaymentProof(
          orderId: orderId, proofUrl: proofUrl, note: note));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<ClockOrderModel>>> getMyOrders() async {
    try {
      return Right(await _dataSource.getMyOrders());
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}
