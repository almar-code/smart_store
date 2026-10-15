import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio dio = Dio();


  Future<List<OrderModel>> getOrders(int customerId) async {
    final response = await dio.get(ApiEndpoints.getOrders(customerId));
    if (response.data['success'] == true) {
      List data = response.data['data'];
      return data.map((e) => OrderModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> cancelOrder(int orderId) async {
    await dio.post(ApiEndpoints.cancelOrder(orderId));
  }
}