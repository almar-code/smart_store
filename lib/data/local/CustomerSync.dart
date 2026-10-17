import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_endpoints.dart';
import '../../data/local/user_local.dart';

class CustomerSyncService {

  /// دالة مستقلة لمزامنة معرف Supabase مع لارافيل وحفظ الـ customer_id الفعلي في Hive
  static Future<void> syncCustomerWithLaravel() async {
    try {
      final box = await Hive.openBox(UserLocal.boxName);
      if (box.isEmpty) return;

      // جلب معرف السوبابيز المخزن في الهيف
      var supabaseId = box.get('user_id') ?? box.get('user_id');
      if (supabaseId == null || supabaseId.toString().isEmpty) return;

      // إرسال الطلب إلى لارافيل لمطابقة المعرف أو إنشائه
      final response = await http.post(
        Uri.parse(ApiEndpoints.syncCustomer),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'supabase_id': supabaseId.toString(),
          'name': box.get('user_name') ?? box.get('name') ?? 'مستخدم جديد',
          'email': box.get('user_email') ?? box.get('email') ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final String customerId = body['customer_id'].toString();

        // تخزين رقم العميل الفعلي في صندوق الهيف ليكون جاهزاً للاستخدام دائماً
        await box.put('customer_id', customerId);
        print('تمت مزامنة العميل بنجاح وحفظ customer_id: $customerId');
      }
    } catch (e) {
      print('خطأ في مزامنة العميل مع لارافيل: $e');
    }
  }
}