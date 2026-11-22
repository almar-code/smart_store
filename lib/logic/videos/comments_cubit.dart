import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/user_local.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repos/product_comment_repository.dart';
import '../../data/repos/video_repo.dart';

// ===================== CommentsState =====================
abstract class CommentsState {}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final int commentsCount;

  CommentsLoaded({required this.comments, required this.commentsCount});
}

class CommentsError extends CommentsState {
  final String message;
  CommentsError(this.message);
}

// نتيجة إرسال تعليق الفيديو
enum VideoCommentResult { accepted, rejected, failed, loginRequired }

// ===================== CommentsCubit =====================
class CommentsCubit extends Cubit<CommentsState> {
  final VideoRepo repository;
  // نفس خدمة تصنيف تعليقات المنتجات
  final ProductCommentRepository classifierRepo;

  CommentsCubit(this.repository, this.classifierRepo) : super(CommentsInitial());

  // نسخة محلية للتحديث السريع
  List<CommentModel> _currentComments = [];

  Future<void> loadComments(int videoId) async {
    emit(CommentsLoading());
    try {
      _currentComments = await repository.fetchComments(videoId);
      emit(CommentsLoaded(
        comments: List.from(_currentComments),
        commentsCount: _currentComments.length,
      ));
    } catch (_) {
      emit(CommentsError(tr('comments_error')));
    }
  }

  Future<VideoCommentResult> sendComment(VideoModel video, String text) async {
    final customerId = await UserLocal().getCustomerId();
    if (customerId == null) return VideoCommentResult.loginRequired;

    final user = await UserLocal().getUser();
    final tempId = DateTime.now().millisecondsSinceEpoch;

    // التعليق المؤقت بالاسم والصورة من Hive
    final temp = CommentModel(
      id: tempId,
      commentText: text,
      customerName: user?.name ?? '',
      customerImage: user?.image,
      videoId: video.videoId,
      createdAt: DateTime.now().toIso8601String(),
      isSending: true,
    );

    _currentComments.insert(0, temp);
    video.commentsCount++;
    _emitLoaded(video);

    // تصنيف التعليق، وعند فشل n8n يكمل الحفظ
    String? classification;
    try {
      classification = await classifierRepo.classifyComment(text);
    } catch (_) {
      classification = null;
    }

    // حذف التعليق المؤقت عند الرفض
    if (classification == 'Inappropriate') {
      _currentComments.removeWhere((e) => e.id == tempId);
      video.commentsCount--;
      _emitLoaded(video);
      return VideoCommentResult.rejected;
    }

    var result = VideoCommentResult.accepted;
    try {
      final server = await repository.postComment(video.videoId, customerId, text);
      final i = _currentComments.indexWhere((e) => e.id == tempId);

      // نحتفظ باسم وصورة Hive اذا رجعت فارغة من السيرفر
      if (i != -1) {
        _currentComments[i] = CommentModel(
          id: server.id,
          commentText: server.commentText,
          customerName: server.customerName.isNotEmpty ? server.customerName : temp.customerName,
          customerImage: (server.customerImage ?? '').isNotEmpty ? server.customerImage : temp.customerImage,
          videoId: server.videoId,
          createdAt: server.createdAt,
        );
      }
    } catch (_) {
      _currentComments.removeWhere((e) => e.id == tempId);
      video.commentsCount--;
      result = VideoCommentResult.failed;
    }

    _emitLoaded(video);
    return result;
  }

  void _emitLoaded(VideoModel video) {
    emit(CommentsLoaded(
      comments: List.from(_currentComments),
      commentsCount: video.commentsCount,
    ));
  }
}