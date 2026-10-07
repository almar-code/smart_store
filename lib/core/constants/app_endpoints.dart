import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // 1. جلب الرابط الأساسي من ملف الـ .env مع القيمة الافتراضية للمحاكي
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.43.224:8000';

  // ====================  روابط عناوين المستخدمين ====================
  static String get userAddresses => '$_baseUrl/api/user-addresses';
  // روابط ثابتة للفيديوهات
  static String get getAllVideos => '$_baseUrl/api/get-all-videos';
// أضف هذا السطر داخل كلاس ApiEndpoints الموجود لديك
  static String get n8nChatAgent => 'https://n8n-production-7bdd.up.railway.app/webhook/abaya-customer-service';
  // روابط ديناميكية (تعتمد على معرف الفيديو videoId)
  static String toggleLike(int videoId) => '$_baseUrl/api/videos/$videoId/like';
  static String incrementShare(int videoId) => '$_baseUrl/api/videos/$videoId/share';
  static String toggleSave(int videoId) => '$_baseUrl/api/videos/$videoId/save';
  static String getComments(int videoId) => '$_baseUrl/api/videos/$videoId/comments';
  static String addComment(int videoId) => '$_baseUrl/api/videos/comments/$videoId';
  // ====================🛍 روابط المنتجات والأقسام الثابتة ====================
  static String get getSubCategories => '$_baseUrl/api/categories';
  static String get getProducts => '$_baseUrl/api/products';
  static String get getCategories => '$_baseUrl/api/sections';
  static String get getCountry => 'https://countriesnow.space/api/v0.1/countries/codes';
  // ====================  روابط المفضلات الجديدة ====================
  // static String get getFavoriteProducts => '$_baseUrl/api/customer/favorites';
  static String get toggleFavorite => '$_baseUrl/api/customer/favorites/toggle';
  static String get favoriteCount => '$_baseUrl/api/customer/favorites/count';
// ====================🛍 روابط ملفات صور  المنتجات والأقسام الثابتة ====================
  static String productImageUrl(String? image) => "$_baseUrl/storage/uploads/products/$image";
  static String countryFlag(String? code) => "https://flagcdn.io/flags/4x3/${code}.svg";
  static String subCategoryImageUrl(String? image) => "$_baseUrl/storage/uploads/subcategory/$image";
  // لعرض محتويات السلة (GET) -> ستحتاج لتمرير customer_id كـ Query Parameter
  static String get getCart => '$_baseUrl/api/cart';
  // لإضافة منتج جديد إلى السلة (POST)
  static String get addToCart => '$_baseUrl/api/cart/add';
  // لتحديث كمية منتج في السلة (PUT) -> تعتمد على معرف السجل في السلة id
  static String updateCartItem(int id) => '$_baseUrl/api/cart/update/$id';
  // لحذف صنف من السلة (DELETE) -> تعتمد على معرف السجل في السلة id
  static String deleteCartItem(int id) => '$_baseUrl/api/cart/delete/$id';

}