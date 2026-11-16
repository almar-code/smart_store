import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/user_local.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/video_model.dart';
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

// ===================== CommentsCubit =====================
class CommentsCubit extends Cubit<CommentsState> {
  final VideoRepo repository;

  CommentsCubit(this.repository) : super(CommentsInitial());

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

  // ترجع false اذا لم يسجل الدخول
  Future<bool> sendComment(VideoModel video, String text) async {
    final customerId = await UserLocal().getCustomerId();
    if (customerId == null) return false;

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
    }

    _emitLoaded(video);
    return true;
  }

  void _emitLoaded(VideoModel video) {
    emit(CommentsLoaded(
      comments: List.from(_currentComments),
      commentsCount: video.commentsCount,
    ));
  }
}