import '../../data/models/notification_model.dart';

// صيغة بيانات الإشعار: النوع:الرقم:الاسم
class NotificationPayload {
  final String type;
  final int? id;
  final String? name;

  const NotificationPayload(this.type, this.id, this.name);

  static String build(NotificationModel n) {
    final id = n.type == 'general_ad' ? n.adsId : n.orderId;
    return '${n.type}:${id ?? ''}:${n.adsName ?? ''}';
  }

  // الاسم هو كل ما بعد النقطتين الثانية
  static NotificationPayload parse(String? payload) {
    final parts = (payload ?? '').split(':');
    final id = parts.length > 1 ? int.tryParse(parts[1]) : null;
    final name = parts.length > 2 ? parts.sublist(2).join(':') : null;
    return NotificationPayload(parts.first, id, (name?.isEmpty ?? true) ? null : name);
  }
}
