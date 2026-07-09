import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // 1. جلب الرابط الأساسي من ملف الـ .env مع القيمة الافتراضية للمحاكي
  static String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000';

  // ====================  روابط الفيديوهات الثابتة والديناميكية ====================

  // روابط ثابتة للفيديوهات
  static String get getAllVideos => '$_baseUrl/api/get-all-videos';

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
// ====================🛍 روابط ملفات صور  المنتجات والأقسام الثابتة ====================
  static String productImageUrl(String? image) => "$_baseUrl/storage/uploads/products/$image";
  static String countryFlag(String? code) => "https://flagcdn.io/flags/4x3/${code}.svg";
  static String subCategoryImageUrl(String? image) => "$_baseUrl/storage/uploads/subcategory/$image";
}