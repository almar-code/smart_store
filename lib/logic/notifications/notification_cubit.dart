import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/local_notification_helper.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/notification_repo.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo repo;

  NotificationCubit(this.repo) : super(const NotificationState());
  Timer? _timer;

  // تحديث تلقائي كل 3 دقائق
  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 3), (_) async {
      await fetch(silent: true);
      // إظهار الجديد في قائمة إشعارات الجوال
      LocalNotificationHelper.checkNew();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
  // Future<int?> _customerId() => UserLocal().getCustomerIdOrNull();
  int? _customerId() => 1;

  // silent: تحديث بدون إظهار التحميل
  Future<void> fetch({bool silent = false}) async {
    final id = await _customerId();
    if (id == null) return emit(const NotificationState());

    // تشغيل فحص إشعارات الجوال بالخلفية
    LocalNotificationHelper.start(id);

    if (!silent) emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final items = await repo.getNotifications(id);
      emit(NotificationState(items: items));
    } catch (_) {
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> markRead(int notificationId) async {
    final id = await _customerId();
    if (id == null) return;
    emit(state.copyWith(
      items: state.items
          .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
          .toList(),
    ));
    await repo.markRead(notificationId, id).catchError((_) {});
  }

  Future<void> markAllRead() async {
    final id = await _customerId();
    if (id == null) return;
    emit(state.copyWith(
      items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
    ));
    await repo.markAllRead(id).catchError((_) {});
  }

  Future<void> delete(int notificationId) async {
    final id = await _customerId();
    if (id == null) return;
    emit(state.copyWith(
      items: state.items.where((n) => n.id != notificationId).toList(),
    ));
    await repo.delete(notificationId, id).catchError((_) {});
  }

  // عند تسجيل الخروج
  void clear() {
    _timer?.cancel();
    LocalNotificationHelper.stop();
    emit(const NotificationState());
  }
}
