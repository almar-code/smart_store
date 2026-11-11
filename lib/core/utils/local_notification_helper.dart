import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../../data/services/notification_service.dart';
import '../../views/screens/cart/cart_screen.dart';
import '../../views/screens/orders/orders_screen.dart';

// مفتاح التنقل العام لفتح السلة من الإشعار
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _task = 'check_store_notifications';

// يعمل بالخلفية حتى لو التطبيق مغلق
@pragma('vm:entry-point')
void notificationCallbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      await dotenv.load(fileName: '.env');
      await LocalNotificationHelper._initPlugin();
      await LocalNotificationHelper.checkNew();
    } catch (_) {}
    return true;
  });
}

class LocalNotificationHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();

  // اندرويد فقط
  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // يستدعى مرة في main
  static Future<void> initApp() async {
    if (!_supported) return;
    await _initPlugin();
    await Workmanager().initialize(notificationCallbackDispatcher);

    // اذا فُتح التطبيق بالضغط على إشعار
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _open(launch!.notificationResponse?.payload),
      );
    }
  }

  static Future<void> _initPlugin() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (r) => _open(r.payload),
    );
  }

  // حفظ رقم العميل وتسجيل الفحص كل 15 دقيقة
  static Future<void> start(int customerId) async {
    if (!_supported) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_customer_id', customerId);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await Workmanager().registerPeriodicTask(
      _task,
      _task,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> stop() async {
    if (!_supported) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notif_customer_id');
    await prefs.remove('notif_last_id');
    await Workmanager().cancelByUniqueName(_task);
  }

  // جلب الجديد وإظهاره في قائمة إشعارات الجوال
  static Future<void> checkNew() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('notif_customer_id');
    if (customerId == null) return;

    // easy_localization يحفظ اللغة بمفتاح locale
    final lang = (prefs.getString('locale') ?? 'ar').startsWith('en') ? 'en' : 'ar';
    final lastId = prefs.getInt('notif_last_id') ?? 0;

    final items = await NotificationApiService().getNotifications(customerId);
    final fresh = items.where((n) => !n.isRead && n.id > lastId).toList();

    for (final n in fresh) {
      await _plugin.show(
        n.id,
        n.title(lang),
        n.body(lang),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'store_channel',
            'Store notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: '${n.type}:${n.orderId ?? ''}',
      );
    }

    if (fresh.isNotEmpty) {
      await prefs.setInt('notif_last_id', fresh.first.id);
    }
  }

  // فتح الشاشة المناسبة حسب نوع الاشعار
  static void _open(String? payload) {
    final parts = (payload ?? '').split(':');
    final orderId = parts.length > 1 ? int.tryParse(parts[1]) : null;

    final Widget? screen = switch (parts.first) {
      'abandoned_cart' => const CartScreen(screenOnly: true),
      'order_status' => OrdersScreen(openOrderId: orderId),
      _ => null,
    };

    if (screen != null) {
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => screen));
    }
  }
}
