import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepo {
  final NotificationApiService service;

  NotificationRepo(this.service);

  Future<List<NotificationModel>> getNotifications(int customerId) =>
      service.getNotifications(customerId);

  Future<void> markRead(int id, int customerId) => service.markRead(id, customerId);

  Future<void> markAllRead(int customerId) => service.markAllRead(customerId);

  Future<void> delete(int id, int customerId) => service.delete(id, customerId);
}
