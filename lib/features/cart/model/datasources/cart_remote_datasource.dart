import '../cart_model.dart';
import '../order_item_model.dart';
import '../order_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addItem(int assetId, int quantity);
  Future<CartModel> updateItem(int itemId, int quantity);
  Future<void> removeItem(int itemId);
  Future<void> clearCart();
  Future<OrderModel> checkout();
  Future<List<OrderModel>> getOrders({String? status, int page = 1});
  Future<OrderModel> getOrderDetail(int id);
  Future<List<OrderItemModel>> getSellerOrderItems({int page = 1});
  Future<void> approveOrderItem(int itemId);
  Future<void> rejectOrderItem(int itemId);
}
