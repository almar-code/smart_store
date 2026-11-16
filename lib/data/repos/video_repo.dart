import '../local/reels_local.dart';
import '../models/comment_model.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

// نتيجة دفعة واحدة
class VideoPage {
  final List<VideoModel> videos;
  final bool hasMore;
  final int total;
  final int totalViews;
  final int totalLikes;

  VideoPage({
    required this.videos,
    required this.hasMore,
    required this.total,
    required this.totalViews,
    required this.totalLikes,
  });
}

class VideoRepo {
  final VideoService service;

  VideoRepo(this.service);

  // دمج حالة اللايك والحفظ من الجهاز
  VideoModel _withLocal(VideoModel v) => v
    ..isLiked = ReelsLocal.isLiked(v.videoId)
    ..isSaved = ReelsLocal.isSaved(v.videoId);

  Future<VideoPage> getVideos({required int page, required int seed}) async {
    final res = await service.getVideos(page: page, seed: seed);
    final List data = res['data'] ?? [];
    final Map meta = res['meta'] ?? {};

    return VideoPage(
      videos: data.map((e) => _withLocal(VideoModel.fromJson(Map<String, dynamic>.from(e)))).toList(),
      hasMore: (meta['current_page'] ?? 1) < (meta['last_page'] ?? 1),
      total: meta['total'] ?? data.length,
      totalViews: meta['total_views'] ?? 0,
      totalLikes: meta['total_likes'] ?? 0,
    );
  }

  Future<VideoModel> getVideo(int videoId) async {
    return _withLocal(VideoModel.fromJson(await service.getVideo(videoId)));
  }

  Future<void> toggleLike(int videoId, bool liked) =>
      service.toggleLike(videoId, liked ? 'like' : 'unlike');

  Future<void> toggleSave(int videoId, bool saved) =>
      service.toggleSave(videoId, saved ? 'save' : 'unsave');

  Future<void> incrementShare(int videoId) => service.incrementShare(videoId);

  Future<void> addView(int videoId) => service.addView(videoId);

  Future<List<CommentModel>> fetchComments(int videoId) async {
    final data = await service.getComments(videoId);
    return data.map<CommentModel>((json) => CommentModel.fromJson(json)).toList();
  }

  Future<CommentModel> postComment(int videoId, int? customerId, String text) async {
    final data = await service.addComment(videoId, customerId, text);
    return CommentModel.fromJson(data);
  }
}