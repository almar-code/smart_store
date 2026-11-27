import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class ReelsCacheHelper {
  // كاش الريلز: 7 أيام و60 فيديو كحد أقصى
  static final CacheManager _cache = CacheManager(
    Config(
      'reels_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 60,
    ),
  );

  // من الكاش ان وجد والا من الشبكة
  static Future<VideoPlayerController> controllerFor(String url) async {
    if (!kIsWeb) {
      final cached = await _cache.getFileFromCache(url);
      if (cached != null) return VideoPlayerController.file(cached.file);
    }
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  // هل الفيديو منزل على الجهاز
  // في الويب لا يوجد تخزين ملفات فنعتبره متاحا ويعتمد على كاش المتصفح
  static Future<bool> isCached(String url) async {
    if (kIsWeb) return true;
    try {
      return await _cache.getFileFromCache(url) != null;
    } catch (_) {
      return false;
    }
  }

  // تنزيل مسبق بالخلفية
  static Future<void> preload(String url) async {
    if (kIsWeb) return;
    try {
      if (await _cache.getFileFromCache(url) == null) {
        await _cache.downloadFile(url);
      }
    } catch (_) {}
  }
}