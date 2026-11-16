import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/video_model.dart';

class ReelsLocal {
  static const String boxName = 'reels_box';
  static Box get _box => Hive.box(boxName);

  // ===== الإعجابات =====
  static Set<int> _likedIds() =>
      Set<int>.from(_box.get('liked', defaultValue: const <int>[]));

  static bool isLiked(int id) => _likedIds().contains(id);

  static Future<void> setLiked(int id, bool liked) async {
    final ids = _likedIds();
    liked ? ids.add(id) : ids.remove(id);
    await _box.put('liked', ids.toList());
  }

  // ===== المحفوظات =====
  static List _raw() => List.from(_box.get('saved', defaultValue: const []));

  static bool isSaved(int id) => _raw().any((e) => e['video_id'] == id);

  // الأحدث أولا
  static List<VideoModel> savedVideos() {
    return _raw().map((e) {
      final video = VideoModel.fromJson(Map<String, dynamic>.from(e));
      return video
        ..isSaved = true
        ..isLiked = isLiked(video.videoId);
    }).toList();
  }

  // يرجع true اذا تم الحفظ
  static Future<bool> toggleSave(VideoModel video) async {
    final raw = _raw();
    final exists = raw.any((e) => e['video_id'] == video.videoId);

    if (exists) {
      raw.removeWhere((e) => e['video_id'] == video.videoId);
    } else {
      raw.insert(0, video.toJson());
    }

    await _box.put('saved', raw);
    return !exists;
  }

  static Future<void> removeSaved(int id) async {
    final raw = _raw()..removeWhere((e) => e['video_id'] == id);
    await _box.put('saved', raw);
  }

  static Future<void> clearSaved() => _box.delete('saved');

  // لتحديث شاشة المحفوظات تلقائيا
  static ValueListenable<Box> listenable() => _box.listenable(keys: ['saved']);
}