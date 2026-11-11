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
      // الاحتفاظ بالقائمة الأصلية حتى نستعيدها عند الرفض.
      final currentState = state;

      final List<ProductCommentModel> originalComments =
      currentState is ProductCommentLoaded
      ? List<ProductCommentModel>.from(currentState.comments)
          : <ProductCommentModel>[];

      // إظهار التعليق مباشرةً في الواجهة، قبل التصنيف.
      final tempComment = ProductCommentModel(
      commentId: -999,
      customerId:  await _customerId(),
      productId: productId,
      commentAr: commentText,
      commentEn: commentText,
      stars: stars,
      customerName: customerName,
      customerImage: customerImage,
      createdAt: 'الآن',
      isSending: true,
      );

      final optimisticComments =
      List<ProductCommentModel>.from(originalComments)
      ..insert(0, tempComment);

      emit(ProductCommentLoaded(optimisticComments));

      try {
      // الخطوة الأولى: إرسال التعليق إلى نموذج n8n للتصنيف.
      final classification = await repo.classifyComment(commentText);

      // الخطوة الثانية: إذا كان غير لائق، لا نستدعي Laravel إطلاقًا.
      if (classification == 'Inappropriate') {
         emit(ProductCommentLoaded(originalComments));

      return CommentSubmitResult.rejected;
      }

      // لا نسمح بأي تصنيف غير متوقع بالمرور.
      const allowedClassifications = {'Positive', 'Negative', 'Neutral',};

      if (!allowedClassifications.contains(classification)) {
      emit(ProductCommentLoaded(originalComments));

      return CommentSubmitResult.failed;
      }

      // الخطوة الثالثة: التعليق مقبول مبدئيًا،
      // لذلك نرسله إلى Laravel للحفظ.
      final updatedComments = await repo.addComment(
          customerId:  await _customerId(),
          productId: productId,
          commentAr: commentText,
          commentEn: commentText,
          stars: stars,
        sentiment: classification,

      );

      // استبدال التعليق المؤقت بالقائمة الحقيقية من Laravel.
      emit(ProductCommentLoaded(updatedComments));

      return CommentSubmitResult.accepted;
      } catch (e) {
      // عند فشل التصنيف أو الاتصال أو الحفظ،
      // نحذف التعليق المؤقت ولا نتركه ظاهرًا كتعليق محفوظ.
      emit(ProductCommentLoaded(originalComments));

        return CommentSubmitResult.failed;
        }
      }

  void removeComment(int commentId) async {
    try {
      final updatedComments = await repo.deleteComment(commentId,  await _customerId());
      emit(ProductCommentLoaded(updatedComments));
    } catch (e) {
      emit(ProductCommentError(e.toString()));
    }
  }
}