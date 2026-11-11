// data/services/product_api_service.dart
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/constants/app_endpoints.dart';

class ProductService {
  final Dio dio = Dio();

  Future<Response> getProductsRaw({int? subCatId, int? categoryId,int? productId, required int page ,int? seed,String? date,bool isDiscount = false,int? adsId,bool isFavorite = false , int? customerId}) async {
    try {
      // تجهيز رقم الصفحة كمعامل أساسي
      Map<String, dynamic> queryParams = {'page': page};

      if (subCatId != null) queryParams['subCatId'] = subCatId;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (productId != null) queryParams['product_id'] = productId;
      if (isDiscount) queryParams['is_discount'] = isDiscount;
      if (adsId != null) queryParams['adsId'] = adsId;
      if (isFavorite)   queryParams['is_favorite'] = isFavorite;
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (seed != null) queryParams['seed'] = seed;
      if (date != null) queryParams['date'] = date;

      final response = await dio.get(
        ApiEndpoints.getProducts,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to connect to the server: $e");
    }
  }
  // 🌟 دالة تفعيل أو إلغاء المفضلة بضغط زر واحدة (Toggle)
  Future<Response> toggleFavoriteRaw({
    required int? customerId,
    required int productId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.toggleFavorite, // رابط الـ POST الخاص بالتعديل
        data: {
          'customer_id': customerId,
          'product_id': productId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to toggle favorite status: $e");
    }
  }
  Future<Response> getAllProductsUnfilteredRaw() async {
    try {
      final response = await dio.get(
        ApiEndpoints.getAllProductsUnfiltered,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to connect to server for all products: $e");
    }
  }
  Future<Response> getVisualSearchProducts({
    required String imagePathOrUrl,
    Uint8List? imageBytes,
    required int page,
    int? seed,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'page': page,
        if (seed != null) 'seed': seed,
      });

      if (imageBytes != null) {
        // صورة من الكاميرا أو المعرض بعد التحويل
        formData.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(imageBytes, filename: 'search.jpg'),
        ));
      } else if (imagePathOrUrl.startsWith('http')) {
        // رابط صورة منتج
        formData.fields.add(MapEntry('image_url', imagePathOrUrl));
      } else {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imagePathOrUrl, filename: imagePathOrUrl.split('/').last),
        ));
      }

      final response = await dio.post(
        ApiEndpoints.visualSearchProducts,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception("Visual Search Repository Error: $e");
    }
  }
  // 👁️ تسجيل مشاهدة منتج
  Future<Response> recordProductViewRaw({required int productId, int? customerId}) async {
    return await dio.post(
      ApiEndpoints.recordProductView(productId),
      data: {if (customerId != null) 'customer_id': customerId},
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
  }

// 🔗 تسجيل مشاركة منتج
  Future<Response> recordProductShareRaw({required int productId}) async {
    return await dio.post(
      ApiEndpoints.recordProductShare(productId),
      options: Options(headers: {'Content-Type': 'application/json', 'Accept': 'application/json'}),
    );
  }
}