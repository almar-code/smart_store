import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repos/video_repo.dart';

// --- CommentsState ---
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

// --- CommentsCubit ---
class CommentsCubit extends Cubit<CommentsState> {
  final VideoRepo repository;

  CommentsCubit(this.repository) : super(CommentsInitial());

  // تخزين مؤقت للقائمة الحالية للتحكم بها محلياً وسريعاً
  List<CommentModel> _currentComments = [];

  void loadComments(int videoId) async {
    emit(CommentsLoading());
    try {
      final comments = await repository.fetchComments(videoId);
      _currentComments = comments;
      emit(CommentsLoaded(comments: _currentComments, commentsCount: _currentComments.length));
    } catch (e) {
      emit(CommentsError("فشل تحميل التعليقات"));
    }
  }
  void sendComment(
      VideoModel video,
      int customerId,
      String text,
      ) async {

    final tempId =
        DateTime.now().millisecondsSinceEpoch;

    final temporaryComment = CommentModel(

      id: tempId,

      commentText: text,

      customerName: "omar",

      customerImage: null,

      videoId: video.videoId,

      createdAt: DateTime.now().toString(),

      isSending: true,
    );

    // إضافة فورية
    _currentComments.insert(0, temporaryComment);

    // زيادة العداد فوراً
    video.commentsCount++;

    emit(
      CommentsLoaded(
        comments: List.from(_currentComments),
        commentsCount: video.commentsCount,
      ),
    );

    try {

      final serverComment =
      await repository.postComment(
        video.videoId,
        customerId,
        text,
      );

      _currentComments.removeWhere(
            (e) => e.id == tempId,
      );

// إضافة الحقيقي مكانه
      _currentComments.insert(0, serverComment);

      emit(
        CommentsLoaded(
          comments: List.from(_currentComments),
          commentsCount: video.commentsCount,
        ),
      );

    } catch (e) {

      print("ERROR SEND COMMENT => $e");

      _currentComments.removeWhere(
            (e) => e.id == tempId,
      );

      video.commentsCount--;

      emit(
        CommentsLoaded(
          comments: List.from(_currentComments),
          commentsCount: video.commentsCount,
        ),
      );
    }
  }
}