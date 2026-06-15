import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import 'cart_model.dart';
import 'order_model.dart';

abstract class CartRepository {
  Future<Either<Failure, CartModel>> getCart();
  Future<Either<Failure, CartModel>> addItem(int assetId, int quantity);
  Future<Either<Failure, CartModel>> updateItem(int itemId, int quantity);
  Future<Either<Failure, void>> removeItem(int itemId);
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, OrderModel>> checkout();
}
