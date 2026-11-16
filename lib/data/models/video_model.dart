import '../../core/constants/app_endpoints.dart';

class VideoModel {
  final int videoId;
  final String videoUrl;
  final int? productId;
  final String? productName;
  final String? productNameEn;
  final String? productImage;
  final String? productPrice;

  int likesCount;
  int savesCount;
  int sharesCount;
  int commentsCount;
  int viewsCount;

  bool isLiked;
  bool isSaved;

  VideoModel({
    required this.videoId,
    required this.videoUrl,
    this.productId,
    this.productName,
    this.productNameEn,
    this.productImage,
    this.productPrice,
    this.likesCount = 0,
    this.savesCount = 0,
    this.sharesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
  });

  // اسم المنتج حسب اللغة
  String? productTitle(String lang) {
    if (lang == 'en' && (productNameEn ?? '').isNotEmpty) return productNameEn;
    return productName;
  }

  static int _int(dynamic v) => int.tryParse('${v ?? 0}') ?? 0;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: _int(json['video_id']),
      videoUrl: json['video_url'] ?? ApiEndpoints.videoUrl(json['video_path'] ?? ''),
      productImage: json['product_image_url'] ?? (json['product_image'] == null ? null : ApiEndpoints.productImageUrl(json['product_image'])),
      productId: json['product_id'] == null ? null : _int(json['product_id']),
      productName: json['product_name'],
      productNameEn: json['product_name_en'],
      productPrice: json['product_price']?.toString(),
      likesCount: _int(json['likes_count']),
      savesCount: _int(json['saves_count']),
      sharesCount: _int(json['shares_count']),
      commentsCount: _int(json['comments_count']),
      viewsCount: _int(json['views_count']),
    );
  }

  // للحفظ في Hive
  Map<String, dynamic> toJson() => {
    'video_id': videoId,
    'video_url': videoUrl,
    'product_id': productId,
    'product_name': productName,
    'product_name_en': productNameEn,
    'product_image_url': productImage,
    'product_price': productPrice,
    'likes_count': likesCount,
    'saves_count': savesCount,
    'shares_count': sharesCount,
    'comments_count': commentsCount,
    'views_count': viewsCount,
  };
}