import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepo {
  final OrderService service;

  OrderRepo(this.service);

  Future<List<OrderModel>> getOrders(int customerId) async {
    return await service.getOrders(customerId);
  }

  Future<void> cancelOrder(int orderId) async {
    await service.cancelOrder(orderId);
  }
}