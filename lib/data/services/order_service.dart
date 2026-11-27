import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';
import '../models/order_model.dart';

class OrderService {
  // حفظ الردود للعرض بدون انترنت
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);

  Future<List<OrderModel>> getOrders(int? customerId) async {
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