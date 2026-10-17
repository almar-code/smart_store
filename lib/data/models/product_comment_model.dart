class ProductCommentModel {
  final int commentId;
  final String customerId;
  final int productId;
  final String commentAr;
  final String commentEn;
  final double stars;
  final String customerName;
  final String? customerImage;
  final String createdAt;
  final bool isSending;

  ProductCommentModel({
    required this.commentId,
    required this.customerId,
    required this.productId,
    required this.commentAr,
    required this.commentEn,
    required this.stars,
    required this.customerName,
    this.customerImage,
    required this.createdAt,
    this.isSending = false,
  });

  factory ProductCommentModel.fromJson(Map<String, dynamic> json) {
    // استخراج بيانات العميل المدمجة من العلاقة Eager Loading في لارافيل
    final customerData = json['customer'] ?? {};

    return ProductCommentModel(
      commentId: int.parse(
        (json['comment_id'] ?? json['id'] ?? 0).toString(),
      ),
      customerId:
        (json['customer_id'] ?? 0).toString(),
      productId: int.parse(
        (json['p_id'] ?? json['product_id'] ?? 0).toString(),
      ),
      commentAr: json['comment_ar'] ?? '',
      commentEn: json['comment_en'] ?? '',
      stars: double.tryParse((json['stars'] ?? '5.0').toString()) ?? 5.0,
      customerName: customerData['name'] ?? json['customer_name'] ?? 'مستخدم',
      customerImage: customerData['profile_image'] ?? json['customer_image'],
      createdAt: (json['created_at'] ?? 'الآن').toString(),
      isSending: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'p_id': productId,
      'comment_ar': commentAr,
      'comment_en': commentEn,
      'stars': stars,
    };
  }
}