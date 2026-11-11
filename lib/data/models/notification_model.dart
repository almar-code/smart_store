class NotificationModel {
  final int id;
  final String type;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;
  final String createdAt;
  final bool isRead;
  final int? orderId; // رقم الطلب لاشعارات الطلبات

  const NotificationModel({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.createdAt,
    required this.isRead,
    this.orderId
  });

  // النص حسب لغة التطبيق
  String title(String lang) => lang == 'ar' ? titleAr : titleEn;
  String body(String lang) => lang == 'ar' ? bodyAr : bodyEn;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['notification_id'],
      type: json['type'] ?? '',
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      bodyAr: json['body_ar'] ?? '',
      bodyEn: json['body_en'] ?? '',
      createdAt: json['created_at'] ?? '',
      isRead: json['read_at'] != null,
      orderId: json['data'] is Map ? int.tryParse('${json['data']['order_id']}') : null,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      titleAr: titleAr,
      titleEn: titleEn,
      bodyAr: bodyAr,
      bodyEn: bodyEn,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      orderId: orderId,
    );
  }
}
