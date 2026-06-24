import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'cart_model.dart';
import 'cart_repository.dart';
import 'datasources/cart_remote_datasource.dart';
import 'order_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _dataSource;

  const CartRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, CartModel>> getCart() => _wrap(_dataSource.getCart);

  @override
  Future<Either<Failure, CartModel>> addItem(int assetId, int quantity) =>
      _wrap(() => _dataSource.addItem(assetId, quantity));

  @override
  Future<Either<Failure, CartModel>> updateItem(int itemId, int quantity) =>
      _wrap(() => _dataSource.updateItem(itemId, quantity));

  @override
  Future<Either<Failure, void>> removeItem(int itemId) =>
      _wrapVoid(() => _dataSource.removeItem(itemId));

  @override
  Future<Either<Failure, void>> clearCart() =>
      _wrapVoid(_dataSource.clearCart);

  @override
  Future<Either<Failure, OrderModel>> checkout() =>
      _wrap(_dataSource.checkout);

  @override
  Future<Either<Failure, OrderModel>> createOrderFromItems(
    List<({int assetId, int quantity})> items,
  ) =>
      _wrap(() => _dataSource.createOrderFromItems(items));

  @override
  Future<Either<Failure, OrderPageResult>> getOrders({
    String? status,
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getOrders(status: status, page: page));

  @override
  Future<Either<Failure, OrderModel>> getOrderDetail(int id) =>
      _wrap(() => _dataSource.getOrderDetail(id));

  @override
  Future<Either<Failure, OrderItemPageResult>> getSellerOrderItems({
    int page = 1,
  }) =>
      _wrap(() => _dataSource.getSellerOrderItems(page: page));

  @override
  Future<Either<Failure, void>> approveOrderItem(int itemId) =>
      _wrapVoid(() => _dataSource.approveOrderItem(itemId));

  @override
  Future<Either<Failure, void>> rejectOrderItem(int itemId) =>
      _wrapVoid(() => _dataSource.rejectOrderItem(itemId));

  Future<Either<Failure, T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Future<Either<Failure, void>> _wrapVoid(Future<void> Function() fn) async {
    try {
      await fn();
      return const Right(null);
    } on ApiException catch (e) {
      return Left(_map(e));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _map(ApiException e) {
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ValidationException) return ValidationFailure(e.message);
    return ServerFailure(e.message);
  }
}
