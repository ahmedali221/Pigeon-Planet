import '../cart_model.dart';
import '../order_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addItem(int assetId, int quantity);
  Future<CartModel> updateItem(int itemId, int quantity);
  Future<void> removeItem(int itemId);
  Future<void> clearCart();
  Future<OrderModel> checkout();
}
