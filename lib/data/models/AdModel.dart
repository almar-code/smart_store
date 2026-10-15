class AdModel {
  final int adsId;
  final String adsName;
  final String adsImage;
  final String type; // 'general', 'link', 'product', 'image'
  final int? productId;
  final String? adsLink;
  final String expiresAt;

  AdModel({
    required this.adsId,
    required this.adsName,
    required this.adsImage,
    required this.type,
    this.productId,
    this.adsLink,
    required this.expiresAt,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      adsId: int.parse(json['ads_id'].toString()),
      adsName: json['AdsName'] ?? '',
      adsImage: json['AdsImage'] ?? '',
      type: json['type'] ?? 'general',
      productId: json['product_id'] != null ? int.tryParse(json['product_id'].toString()) : null,
      adsLink: json['AdsLink'],
      expiresAt: json['expires_at'] ?? '',
    );
  }
}