import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';

class VideoService {
  final Dio dio = Dio();

  // 1. جلب الفيديوهات
  Future<List<dynamic>> getVideos() async {
    final response = await dio.get(ApiEndpoints.getAllVideos);
    return response.data['data'];
  }

  // 2. تحديث الإعجاب
  Future<Response> toggleLike(int videoId, String action) async {
    return await dio.post(
      ApiEndpoints.toggleLike(videoId),
      data: {'action': action},
    );
  }

  // 3. زيادة المشاركة
  Future<Response> incrementShare(int videoId) async {
    return await dio.post(ApiEndpoints.incrementShare(videoId));
  }

  // 4. زيادة الحفظ
  Future<Response> toggleSave(int videoId) async {
    return await dio.post(ApiEndpoints.toggleSave(videoId));
  }


  // أضف هذه الدوال داخل كلاس VideoService الحالي:
  Future<List<dynamic>> getComments(int videoId) async {
    final response = await dio.get(ApiEndpoints.getComments(videoId));
    return response.data['data'];
  }

  Future<Map<String, dynamic>> addComment(int videoId, int customerId, String text) async {
    final response = await dio.post(
      ApiEndpoints.addComment(videoId),
      data: {'customer_id': customerId, 'comment_text': text},
    );

    // 👈 التعديل هنا: نقوم بإرجاع response.data مباشرة لأن السيرفر يرسل الكائن بدون تغليفه بـ 'data'
    return response.data as Map<String, dynamic>;
  }
}