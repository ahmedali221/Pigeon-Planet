import '../cart_model.dart';
import '../order_item_model.dart';
import '../order_model.dart';

typedef OrderPageResult = ({List<OrderModel> items, bool hasMore});
typedef OrderItemPageResult = ({List<OrderItemModel> items, bool hasMore});

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addItem(int assetId, int quantity);
  Future<CartModel> updateItem(int itemId, int quantity);
  Future<void> removeItem(int itemId);
  Future<void> clearCart();
  Future<OrderModel> checkout();
  Future<OrderModel> createOrderFromItems(
    List<({int assetId, int quantity})> items,
  );
  Future<OrderPageResult> getOrders({String? status, int page = 1});
  Future<OrderModel> getOrderDetail(int id);
  Future<OrderItemPageResult> getSellerOrderItems({int page = 1});
  Future<void> approveOrderItem(int itemId);
  Future<void> rejectOrderItem(int itemId);
}
