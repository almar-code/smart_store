import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // 1. جلب الرابط الأساسي من ملف الـ .env مع القيمة الافتراضية للمحاكي
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.43.224:8000';

  // ====================  روابط عناوين المستخدمين ====================
  static String get userAddresses => '$_baseUrl/api/user-addresses';
  // روابط ثابتة للفيديوهات
  static String get getAllVideos => '$_baseUrl/api/get-all-videos';
// أضف هذا السطر داخل كلاس ApiEndpoints الموجود لديك
  static String get n8nChatAgent => 'https://smartabayastore.app.n8n.cloud/webhook/abaya-customer-service';
  // ==================== روابط ملفات الصور (عبر /api/media لدعم CORS على الويب) ====================
  static String _media(String folder, String? image) =>
      '$_baseUrl/api/media/uploads/$folder/$image';

  static String productImageUrl(String? image) => _media('products', image);
  static String subCategoryImageUrl(String? image) => _media('subcategory', image);
  static String adImageUrl(String imageName) => _media('Advertisement', imageName);
//   static String get n8nChatAgent => 'https://n8n-production-7bdd.up.railway.app/webhook/abaya-customer-service';
  // ==================== 📏 رابط التنبؤ بمقاس العباية (n8n) ====================
  static String get n8nSizePredictor => 'https://almar33.app.n8n.cloud/webhook/abaya-size';
  static const String classifyProductComment = 'https://almar33.app.n8n.cloud/webhook/comment';
  // روابط ديناميكية (تعتمد على معرف الفيديو videoId)
  static String toggleLike(int videoId) => '$_baseUrl/api/videos/$videoId/like';
  static String incrementShare(int videoId) => '$_baseUrl/api/videos/$videoId/share';
  static String toggleSave(int videoId) => '$_baseUrl/api/videos/$videoId/save';
  static String getComments(int videoId) => '$_baseUrl/api/videos/$videoId/comments';
  static String addComment(int videoId) => '$_baseUrl/api/videos/comments/$videoId';
  // ==================== روابط المنتجات والأقسام الثابتة ====================
  static String get getSubCategories => '$_baseUrl/api/categories';
  static String get getProducts => '$_baseUrl/api/products';
  static String get getAllProductsUnfiltered => '$_baseUrl/api/products/all-unfiltered';
  static String get getCategories => '$_baseUrl/api/sections';
  static String get getCountry => 'https://countriesnow.space/api/v0.1/countries/codes';
  // ====================  روابط المفضلات الجديدة ====================
  // static String get getFavoriteProducts => '$_baseUrl/api/customer/favorites';
  static String get toggleFavorite => '$_baseUrl/api/customer/favorites/toggle';
  static String get favoriteCount => '$_baseUrl/api/customer/favorites/count';
// ==================== روابط ملفات صور  المنتجات والأقسام الثابتة ====================
//   static String productImageUrl(String? image) => "$_baseUrl/storage/uploads/products/$image";
  static String countryFlag(String? code) => "https://flagcdn.io/flags/4x3/${code}.svg";
  // static String subCategoryImageUrl(String? image) => "$_baseUrl/storage/uploads/subcategory/$image";
  // لعرض محتويات السلة (GET) -> ستحتاج لتمرير customer_id كـ Query Parameter
  static String get getCart => '$_baseUrl/api/cart';
  // لإضافة منتج جديد إلى السلة (POST)
  static String get addToCart => '$_baseUrl/api/cart/add';
  // لتحديث كمية منتج في السلة (PUT) -> تعتمد على معرف السجل في السلة id
  static String updateCartItem(int id) => '$_baseUrl/api/cart/update/$id';
  // لحذف صنف من السلة (DELETE) -> تعتمد على معرف السجل في السلة id
  static String deleteCartItem(int id) => '$_baseUrl/api/cart/delete/$id';

  // روابط الإعلانات
  static String get getAllAds => '$_baseUrl/api/get-ads';
  static String generalAdProducts(int adsId) => '$_baseUrl/api/ads/$adsId/products';

  // دالة مساعدة لترتيب مسار صور الإعلانات
  // static String adImageUrl(String imageName) => '$_baseUrl/storage/uploads/Advertisement/$imageName';
  // ==================== روابط عمليات الدفع (Payment Endpoints) ====================
  static String get getPaymentMethods => '$_baseUrl/api/payments/methods';
  static String get setupCard => '$_baseUrl/api/payments/methods/setup';
  static String get syncCard => '$_baseUrl/api/payments/methods/sync';
  static String get createPaymentIntent => '$_baseUrl/api/payments/create-intent';
  static String deletePaymentMethod(int paymentMethodId) => '$_baseUrl/api/payments/methods/$paymentMethodId';
  static String get startCheckout => '$_baseUrl/api/checkout/start';
  static String get getStorePaymentAccounts => '$_baseUrl/api/store-payment-accounts';
  static String get createManualCheckout => '$_baseUrl/api/manual-payment/checkout';
  // ====================  روابط الطلبات (Order Endpoints) ====================
  static String getOrders(int? customerId) => '$_baseUrl/api/orders/$customerId';
  static String cancelOrder(int orderId) => '$_baseUrl/api/orders/cancel/$orderId';
//  الرابط الجديد المضاف الخاص بجلب وطباعة فاتورة الطلب بصيغة PDF من لارافيل
  static String orderInvoice(int orderId) => '$_baseUrl/api/orders/$orderId/invoice';
  static String get visualSearchProducts => '$_baseUrl/api/products/visual-search';

  // ==================== 💬 روابط تعليقات المنتجات ====================
  // جلب تعليقات منتج معين (GET)
  static String getProductComments(int productId) => '$_baseUrl/api/products/$productId/comments';

  // إضافة تعليق جديد (POST)
  static String get addProductComment => '$_baseUrl/api/product-comments';

  // حذف تعليق (DELETE)
  static String deleteProductComment(int commentId) => '$_baseUrl/api/product-comments/$commentId';

  static String get syncCustomer => '$_baseUrl/api/customers/sync-supabase';
  // ==================== التجربة الحية (Decart) ====================
  static String get decartApiKey => dotenv.env['DECART_API_KEY'] ?? '';
  static int get liveTryOnSeconds => int.tryParse(dotenv.env['LIVE_TRYON_SECONDS'] ?? '') ?? 60;
  // ==================== التجربة بالصورة (Decart - Lucy Image) ====================
  static String get decartImageEdit => 'https://api.decart.ai/v1/generate/lucy-image-2';
  // ==================== روابط إحصائيات المنتج ====================
  static String recordProductView(int productId) => '$_baseUrl/api/products/$productId/view';
  static String recordProductShare(int productId) => '$_baseUrl/api/products/$productId/share';
  // ==================== روابط الإشعارات ====================
  static String get notifications => '$_baseUrl/api/notifications';
  static String get readAllNotifications => '$_baseUrl/api/notifications/read-all';
  static String readNotification(int id) => '$_baseUrl/api/notifications/$id/read';
  static String deleteNotification(int id) => '$_baseUrl/api/notifications/$id';
}