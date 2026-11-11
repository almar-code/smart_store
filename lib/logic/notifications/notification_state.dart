import '../../data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> items;
  final bool isLoading;
  final bool hasError;

  const NotificationState({
    this.items = const [],
    this.isLoading = false,
    this.hasError = false,
  });

  // عدد غير المقروء للجرس
  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationModel>? items,
    bool? isLoading,
    bool? hasError,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}
