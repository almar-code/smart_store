import 'package:intl/intl.dart' as intl;

class DateHelper {
  static String formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      // يمكنك تعديل التنسيق بالطريقة التي تفضلها
      return intl.DateFormat('yyyy-MM-dd  hh:mm a', 'en').format(dateTime);
    } catch (e) {
      return dateStr; // في حال حدث أي خطأ يعيد النص كما هو
    }
  }

  // إذا أردت تنسيق التاريخ فقط بدون الوقت
  static String formatDateOnly(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return intl.DateFormat('yyyy-MM-dd', 'en').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}