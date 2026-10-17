import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_comment_model.dart';
import '../../data/repos/product_comment_repository.dart';
import 'product_comment_state.dart';

class ProductCommentCubit extends Cubit<ProductCommentState> {
  final ProductCommentRepository repo;

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

  void sendComment({
    required String customerId,
    required int productId,
    required String commentText,
    required double stars,
    required String customerName, // اسم العميل الحالي لعرضه فوراً
    String? customerImage,        // صورة العميل الحالي
  }) async {
    // 1. جلب القائمة الحالية إذا كانت محملة
    final currentState = state;
    List<ProductCommentModel> currentComments = [];
    if (currentState is ProductCommentLoaded) {
      currentComments = List.from(currentState.comments);
    }

    // 2. إنشاء تعليق افتراضي مؤقت يظهر فوراً في الواجهة مع isSending = true
    final tempComment = ProductCommentModel(
      commentId: -999, // معرف مؤقت مميز
      customerId: customerId,
      productId: productId,
      commentAr: commentText,
      commentEn: commentText,
      stars: stars,
      customerName: customerName,
      customerImage: customerImage,
      createdAt: 'الآن',
      isSending: true, // مؤشر بأنه قيد الإرسال
    );

    // 3. إضافة التعليق المؤقت في أعلى القائمة وإظهاره للمستخدم فوراً
    currentComments.insert(0, tempComment);
    emit(ProductCommentLoaded(currentComments));

    try {
      // 4. إرسال الطلب الفعلي للسيرفر
      final updatedComments = await repo.addComment(
        customerId: customerId,
        productId: productId,
        commentAr: commentText,
        commentEn: commentText,
        stars: stars,
      );

      // 5. استبدال القائمة المؤقتة بالقائمة الحقيقية القادمة من لارافيل
      emit(ProductCommentLoaded(updatedComments));
    } catch (e) {
      // في حال حدث خطأ، يمكنك إعادة القائمة القديمة أو تنبيه المستخدم
      emit(ProductCommentError(e.toString()));
    }
  }

  void removeComment(int commentId, String customerId) async {
    try {
      final updatedComments = await repo.deleteComment(commentId, customerId);
      emit(ProductCommentLoaded(updatedComments));
    } catch (e) {
      emit(ProductCommentError(e.toString()));
    }
  }
}