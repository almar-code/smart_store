import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static const String savedVideosKey = "saved_videos";

  // جلب الفيديوهات المحفوظة
  static Future<List<String>> getSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(savedVideosKey) ?? [];
  }

  // هل الفيديو محفوظ؟
  static Future<bool> isVideoSaved(int videoId) async {

    final saved = await getSavedVideos();

    return saved.contains(videoId.toString());
  }

  // حفظ / حذف
  static Future<bool> toggleSaveVideo(int videoId) async {

    final prefs = await SharedPreferences.getInstance();

    List<String> saved =
        prefs.getStringList(savedVideosKey) ?? [];

    if(saved.contains(videoId.toString())){

      saved.remove(videoId.toString());

      await prefs.setStringList(savedVideosKey, saved);

      return false;

    }else{

      saved.add(videoId.toString());

      await prefs.setStringList(savedVideosKey, saved);

      return true;
    }
  }
}