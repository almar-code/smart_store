import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_endpoints.dart';
import '../../data/models/product_comment_model.dart';

class ProductCommentService {


  // تصنيف التعليق قبل إرساله إلى Laravel
  Future<String> classifyComment(String comment) async {
      final response = await http
          .post(
        Uri.parse(ApiEndpoints.classifyProductComment),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain',
        },
        body: jsonEncode({
          'comment': comment,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception('تعذر التحقق من التعليق');
      }

      final dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        // يسمح أيضًا باستجابة نصية مباشرة مثل Positive
        return _validateClassification(response.body);
      }

      final result = _extractClassification(decoded);

      if (result == null) {
        throw Exception('استجابة التصنيف غير صالحة');
      }

      return _validateClassification(result);
    }

  // استخراج التصنيف سواء أرجعه n8n كنص أو JSON
  String? _extractClassification(dynamic data) {
    if (data is String) {
      return data.trim();
    }

    if (data is List && data.isNotEmpty) {
      return _extractClassification(data.first);
    }

    if (data is Map) {
      for (final key in ['sentiment','output','text','response','classification','label','result']) {
        if (data.containsKey(key)) {
          final result = _extractClassification(data[key]);

          if (result != null) {
            return result;
          }
        }
      }
    }
    return null;
  }

  // لا نسمح إلا بالتصنيفات الأربعة المعروفة
    String _validateClassification(String value) {
      final classification = value.trim();

      const allowed = {'Positive', 'Negative', 'Neutral', 'Inappropriate',};

      if (!allowed.contains(classification)) {
        throw Exception('نتيجة التصنيف غير معروفة');
      }

      return classification;
    }

  // جلب التعليقات
  Future<List<ProductCommentModel>> getComments(int productId) async {
    final response = await http.get(Uri.parse(ApiEndpoints.getProductComments(productId)));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => ProductCommentModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل في جلب التعليقات');
    }
  }

  // إضافة تعليق وإرجاع القائمة المحدثة
  Future<List<ProductCommentModel>> addComment({
    required int? customerId,
    required int productId,
    required String commentAr,
    required String commentEn,
    required double stars,
    required String sentiment,
  }) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.addProductComment),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'p_id': productId,
        'comment_ar': commentAr,
        'comment_en': commentEn,
        'stars': stars,
        'sentiment': sentiment,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => ProductCommentModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل في إضافة التعليق');
    }
  }

  // حذف التعليق وإرجاع القائمة المحدثة
  Future<List<ProductCommentModel>> deleteComment(int commentId, int? customerId) async {
    final response = await http.delete(
      Uri.parse(ApiEndpoints.deleteProductComment(commentId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'customer_id': customerId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => ProductCommentModel.fromJson(e)).toList();
    } else {
      throw Exception('فشل في حذف التعليق');
    }
  }
}