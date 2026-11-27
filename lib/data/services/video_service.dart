import 'package:dio/dio.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';

class VideoService {
  // حفظ قائمة الريلز للعرض بدون انترنت
  final Dio dio = Dio()..interceptors.add(AppCache.interceptor);

  // دفعة من الريلز
  Future<Map<String, dynamic>> getVideos({
    required int page,
    required int seed,
    int perPage = 6,
  }) async {
    final response = await dio.get(
      ApiEndpoints.getAllVideos,
      queryParameters: {'page': page, 'per_page': perPage, 'seed': seed},
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> getVideo(int videoId) async {
    final response = await dio.get(ApiEndpoints.getVideo(videoId));
    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<void> toggleLike(int videoId, String action) async {
    await dio.post(ApiEndpoints.toggleLike(videoId), data: {'action': action});
  }

  Future<void> incrementShare(int videoId) async {
    await dio.post(ApiEndpoints.incrementShare(videoId));
  }

  Future<void> toggleSave(int videoId, String action) async {
    await dio.post(ApiEndpoints.toggleSave(videoId), data: {'action': action});
  }

  Future<void> addView(int videoId) async {
    await dio.post(ApiEndpoints.addView(videoId));
  }

  Future<List<dynamic>> getComments(int videoId) async {
    final response = await dio.get(ApiEndpoints.getComments(videoId));
    return response.data['data'];
  }

  Future<Map<String, dynamic>> addComment(int videoId, int? customerId, String text) async {
    final response = await dio.post(
      ApiEndpoints.addComment(videoId),
      data: {'customer_id': customerId, 'comment_text': text},
    );
    return response.data as Map<String, dynamic>;
  }
}