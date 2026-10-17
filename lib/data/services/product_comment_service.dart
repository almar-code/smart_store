import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_endpoints.dart';
import '../../data/models/product_comment_model.dart';

class ProductCommentService {

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
    required String customerId,
    required int productId,
    required String commentAr,
    required String commentEn,
    required double stars,
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
  Future<List<ProductCommentModel>> deleteComment(int commentId, String customerId) async {
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