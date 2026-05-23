import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageHelper {


  static Future<String?> convertUrlToBase64(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;

        String base64String = base64Encode(imageBytes);

        print("✅ تم تحويل الصورة بنجاح");
        return base64String;
      } else {
        print("❌ فشل تحميل الصورة: كود الحالة ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ حدث خطأ أثناء التحويل: $e");
      return null;
    }
  }

  static Uint8List decodeBase64(String base64String) {
    return base64Decode(base64String);
  }
}