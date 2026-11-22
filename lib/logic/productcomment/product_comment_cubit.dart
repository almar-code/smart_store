import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/user_local.dart';
import '../../data/models/product_comment_model.dart';
import '../../data/repos/product_comment_repository.dart';
import 'product_comment_state.dart';

enum CommentSubmitResult {
  accepted,
  rejected,
  failed,
}

class ProductCommentCubit extends Cubit<ProductCommentState> {
  final ProductCommentRepository repo;
  Future<int?> _customerId() => UserLocal().getCustomerId();

  ProductCommentCubit({required ProductCommentRepository repository})
      : repo = repository,
        super(ProductCommentInitial());

  void loadComments(int productId) async {
    emit(ProductCommentLoading());
    try {
      final comments = await repo.getComments(productId);
      emit(ProductCommentLoaded(comments));
    } catch (e) {
      emit(ProductCommentError(e.toString()));
    }
  }

  Future<CommentSubmitResult> sendComment({
    required int productId,
    required String commentText,
    required double stars,
    required String customerName,
    String? customerImage,
  }) async {
    // الاحتفاظ بالقائمة الأصلية لاستعادتها عند الرفض
    final currentState = state;

    final List<ProductCommentModel> originalComments =
    currentState is ProductCommentLoaded
        ? List<ProductCommentModel>.from(currentState.comments)
        : <ProductCommentModel>[];

    // إظهار التعليق مباشرة قبل التصنيف
    final tempComment = ProductCommentModel(
      commentId: -999,
      customerId: await _customerId(),
      productId: productId,
      commentAr: commentText,
      commentEn: commentText,
      stars: stars,
      customerName: customerName,
      customerImage: customerImage,
      createdAt: 'الآن',
      isSending: true,
    );

    final optimisticComments = List<ProductCommentModel>.from(originalComments)
      ..insert(0, tempComment);

    emit(ProductCommentLoaded(optimisticComments));

    // تصنيف التعليق، وعند فشل n8n يكمل بدون تصنيف
    String? classification;
    try {
      classification = await repo.classifyComment(commentText);
    } catch (_) {
      classification = null;
    }

    // رفض التعليق غير اللائق بدون حفظ
    if (classification == 'Inappropriate') {
      emit(ProductCommentLoaded(originalComments));
      return CommentSubmitResult.rejected;
    }

    // أي تصنيف غير معروف يرسل فارغ ويعتمد Laravel على النجوم
    const allowedClassifications = {'Positive', 'Negative', 'Neutral'};
    if (!allowedClassifications.contains(classification)) {
      classification = null;
    }

    try {
      // حفظ التعليق في Laravel
      final updatedComments = await repo.addComment(
        customerId: await _customerId(),
        productId: productId,
        commentAr: commentText,
        commentEn: commentText,
        stars: stars,
        sentiment: classification,
      );

      emit(ProductCommentLoaded(updatedComments));
      return CommentSubmitResult.accepted;
    } catch (e) {
      // فشل الحفظ في Laravel فقط
      emit(ProductCommentLoaded(originalComments));
      return CommentSubmitResult.failed;
    }
  }

  void removeComment(int commentId) async {
    try {
      final updatedComments = await repo.deleteComment(commentId, await _customerId());
      emit(ProductCommentLoaded(updatedComments));
    } catch (e) {
      emit(ProductCommentError(e.toString()));
    }
  }
}