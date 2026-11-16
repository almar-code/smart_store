import '../../data/models/video_model.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoEmpty extends VideoState {}

class VideoLoaded extends VideoState {
  final List<VideoModel> videos;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;
  final int totalViews;
  final int totalLikes;
  final int version; // يتغير عند التحديث

  VideoLoaded({
    required this.videos,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.total = 0,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.version = 0,
  });

  VideoLoaded copyWith({List<VideoModel>? videos, bool? hasMore, bool? isLoadingMore}) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      total: total,
      totalViews: totalViews,
      totalLikes: totalLikes,
      version: version,
    );
  }
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}