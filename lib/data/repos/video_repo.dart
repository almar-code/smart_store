import '../models/comment_model.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

class VideoRepo {
  final VideoService service;

  VideoRepo(this.service);

  // تحويل لستة الـ JSON إلى لستة من الـ VideoModel
  Future<List<VideoModel>> getVideos() async {
    final data = await service.getVideos();
    return data.map<VideoModel>((json) => VideoModel.fromJson(json)).toList();
  }

  Future<void> toggleLike(int videoId, bool isLikedNow) async {
    String action = isLikedNow ? 'like' : 'unlike';
    await service.toggleLike(videoId, action);
  }

  Future<void> incrementShare(int videoId) async {
    await service.incrementShare(videoId);
  }

  Future<void> toggleSave(int videoId) async {
    await service.toggleSave(videoId);
  }


  // داخل كلاس VideoRepo الحالي:
  Future<List<CommentModel>> fetchComments(int videoId) async {
    final data = await service.getComments(videoId);
    return data.map<CommentModel>((json) => CommentModel.fromJson(json)).toList();
  }

  Future<CommentModel> postComment(int videoId, int customerId, String text) async {
    final data = await service.addComment(videoId, customerId, text);
    return CommentModel.fromJson(data);
  }
}