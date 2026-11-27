import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

// حفظ ردود السيرفر على الجهاز لعرضها بدون انترنت
// مع النت: الطلب يذهب للسيرفر دائما ويحفظ الرد
// بدون نت او عند تعطل السيرفر: يرجع اخر رد محفوظ لنفس الطلب
class AppCache {
  AppCache._();

  static CacheStore _store = MemCacheStore();
  static bool _ready = false;

  // تهيئة المخزن قبل تشغيل التطبيق
  static Future<void> init() async {
    if (_ready) return;
    try {
      final String? dir = kIsWeb ? null : (await getApplicationSupportDirectory()).path;
      _store = HiveCacheStore(dir, hiveBoxName: 'nice_api_cache');
      _ready = true;
    } catch (e) {
      // عند الفشل نكمل بذاكرة مؤقتة حتى لا يتوقف التطبيق
      debugPrint('AppCache init error: $e');
    }
  }

  static CacheOptions get options => CacheOptions(
        store: _store,
        // نطلب من السيرفر دائما ونحفظ الرد حتى لو السيرفر لم يطلب الحفظ
        policy: CachePolicy.refreshForceCache,
        // الرجوع للمحفوظ عند انقطاع النت
        hitCacheOnNetworkFailure: true,
        // والرجوع للمحفوظ عند تعطل السيرفر
        hitCacheOnErrorCodes: const [500, 502, 503, 504],
        // حذف الردود الاقدم من اسبوعين
        maxStale: const Duration(days: 14),
        priority: CachePriority.high,
      );

  // يضاف الى Dio في خدمات القراءة فقط
  static DioCacheInterceptor get interceptor => DioCacheInterceptor(options: options);

  // مسح كل المحفوظ مثل عند تسجيل الخروج
  static Future<void> clear() => _store.clean();
}
