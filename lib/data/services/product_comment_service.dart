import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_endpoints.dart';
import '../../core/network/app_cache.dart';
import '../../data/models/product_comment_model.dart';

class ProductCommentService {
  // جلب التعليقات يحفظ للعرض بدون انترنت
  final Dio _dio = Dio()..interceptors.add(AppCache.interceptor);

  // التصنيف بدون حفظ وبمهلة قصيرة حتى لا ينتظر العميل طويلا
  final Dio _classifier = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
    ),
  );

  static final Options _json = Options(
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  // تصنيف التعليق قبل إرساله إلى Laravel
  Future<String> classifyComment(String comment) async {
    final response = await _classifier.post(
      ApiEndpoints.classifyProductComment,
      data: {'comment': comment},
      options: Options(
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json, text/plain'},
        // نستقبل النص كما هو لنقبل JSON او نص مباشر
        responseType: ResponseType.plain,
      ),
    );

    final String raw = (response.data ?? '').toString();
    debugPrint('comment classification raw: $raw');

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      // استجابة نصية مباشرة مثل Positive
      decoded = raw;
    }

    final result = _extractClassification(decoded);
    if (result == null) throw Exception('استجابة التصنيف غير صالحة');

    return _normalize(result);
  }

  // استخراج التصنيف سواء أرجعه n8n كنص أو JSON
  String? _extractClassification(dynamic data) {
    if (data is String) return data.trim();
    if (data is List && data.isNotEmpty) return _extractClassification(data.first);
    if (data is Map) {
      for (final key in ['sentiment', 'output', 'text', 'response', 'classification', 'label', 'result']) {
        if (data.containsKey(key)) {
          final result = _extractClassification(data[key]);
          if (result != null) return result;
        }
      }
    }
    return null;
  }

  // توحيد رد النموذج لاحد التصنيفات الاربعة مهما كانت الكتابة
  String _normalize(String value) {
    final v = value.toLowerCase().replaceAll(RegExp(r'[^a-z\u0600-\u06FF]'), ' ').trim();

    final tokens = v.split(RegExp(r'\s+')).toSet();
    bool has(List<String> words) => words.any(v.contains);

    // السب اولا حتى لا يحسب سلبيا
    if (tokens.contains('سب') ||
        has(['inappropriate', 'offensive', 'insult', 'abusive', 'toxic', 'profan', 'مسيء', 'مسيئ', 'شتم', 'غير لائق', 'بذيء'])) {
      return 'Inappropriate';
    }
    if (has(['negative', 'سلبي'])) return 'Negative';
    if (has(['positive', 'ايجابي', 'إيجابي'])) return 'Positive';
    if (has(['neutral', 'محايد', 'طبيعي'])) return 'Neutral';

    throw Exception('نتيجة التصنيف غير معروفة: $value');
  }

  // جلب التعليقات
  Future<List<ProductCommentModel>> getComments(int productId) async {
    final response = await _dio.get(ApiEndpoints.getProductComments(productId), options: _json);
    return _parseList(response, 'فشل في جلب التعليقات');
  }

  // إضافة تعليق وإرجاع القائمة المحدثة
  Future<List<ProductCommentModel>> addComment({
    required int? customerId,
    required int productId,
    required String commentAr,
    required String commentEn,
    required double stars,
    String? sentiment,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.addProductComment,
      data: {
        'customer_id': customerId,
        'p_id': productId,
        'comment_ar': commentAr,
        'comment_en': commentEn,
        'stars': stars,
        'sentiment': sentiment,
      },
      options: _json,
    );
    return _parseList(response, 'فشل في إضافة التعليق');
  }

  // حذف التعليق وإرجاع القائمة المحدثة
  Future<List<ProductCommentModel>> deleteComment(int commentId, int? customerId) async {
    final response = await _dio.delete(
      ApiEndpoints.deleteProductComment(commentId),
      data: {'customer_id': customerId},
      options: _json,
    );
    return _parseList(response, 'فشل في حذف التعليق');
  }

  // تحويل الرد الى قائمة تعليقات
  List<ProductCommentModel> _parseList(Response response, String error) {
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300) throw Exception(error);
    final body = response.data is String ? jsonDecode(response.data) : response.data;
    final List data = body['data'];
    return data.map((e) => ProductCommentModel.fromJson(e)).toList();
  }
}