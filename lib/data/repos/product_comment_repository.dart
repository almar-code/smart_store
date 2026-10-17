import '../models/product_comment_model.dart';
import '../services/product_comment_service.dart';

class ProductCommentRepository {
  final ProductCommentService apiService;

  ProductCommentRepository({required this.apiService});

  Future<List<ProductCommentModel>> getComments(int productId) async {
    return await apiService.getComments(productId);
  }

  Future<List<ProductCommentModel>> addComment({
    required String customerId,
    required int productId,
    required String commentAr,
    required String commentEn,
    required double stars,
  }) async {
    return await apiService.addComment(
      customerId: customerId,
      productId: productId,
      commentAr: commentAr,
      commentEn: commentEn,
      stars: stars,
    );
  }

  Future<List<ProductCommentModel>> deleteComment(int commentId, String customerId) async {
    return await apiService.deleteComment(commentId, customerId);
  }
}