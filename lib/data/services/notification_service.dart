import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  final Dio _dio = Dio();

  Future<List<NotificationModel>> getNotifications(int customerId) async {
    final res = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'customer_id': customerId},
    );
    final List data = res.data['data'] ?? [];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markRead(int id, int customerId) async {
    await _dio.post(ApiEndpoints.readNotification(id), data: {'customer_id': customerId});
  }

  Future<void> markAllRead(int customerId) async {
    await _dio.post(ApiEndpoints.readAllNotifications, data: {'customer_id': customerId});
  }

  Future<void> delete(int id, int customerId) async {
    await _dio.delete(
      ApiEndpoints.deleteNotification(id),
      queryParameters: {'customer_id': customerId},
    );
  }
}
