class VideoModel {
  final int videoId;
  final String videoUrl;
  final int? productId;
  final String productName;

  int likesCount;
  int savesCount;
  int sharesCount;
  int commentsCount;

  bool isLiked;
  bool isSaved;

  VideoModel({
    required this.videoId,
    required this.videoUrl,
    this.productId,
    required this.productName,
    required this.likesCount,
    required this.savesCount,
    required this.sharesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: int.parse(
        json['video_id'].toString(),
      ),
      videoUrl: json['video_url'],
      productId: json['product_id'],
      productName: json['product_name'] ?? 'Nice Store',
      likesCount: int.parse(
        json['likes_count'].toString(),
      ),
      savesCount: json['saves_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: false,
    );
  }
}