import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_endpoints.dart';
// إذا كنت تستخدم DioClient مخصص في مشروعك، يمكنك استدعاؤه هنا بدلاً من إنشاء نسخة جديدة

class PrintingService {
  static Future<Uint8List?> fetchOrderInvoicePdf(int orderId,String currentLang) async {
    try {
      final dio = Dio(); // أو استخدم مثيل الـ Dio الخاص بمشروعك (DioClient.instance)
      final response = await dio.get(
        ApiEndpoints.orderInvoice(orderId),
        options: Options(
          responseType: ResponseType.bytes, // ضروري جداً لاستقبال الملف كـ Binary/Bytes
          headers: {
            'Accept': 'application/json',
            'Accept-Language': currentLang, // إرسال اللغة الحالية للسيرفر
            // 'Authorization': 'Bearer YOUR_TOKEN', // أضف التوكن هنا إذا كان مطلوباً
          },
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      // يمكنك طباعة الخطأ أو معالجته حسب الحاجة
      return null;
    }
  }
}