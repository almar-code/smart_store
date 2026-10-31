import 'package:hive/hive.dart';

class SearchLocal {
  static const String _boxName = 'search_history_box';

  // حفظ كلمة بحث جديدة (بدون تكرار، وحد أقصى مثلاً 10 كلمات)
  static Future<void> saveSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    var box = await Hive.openBox(_boxName);
    List<String> history = getSearchHistory();

    // إزالة الكلمة إذا كانت موجودة مسبقاً ليتم وضعها في المقدمة
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);

    // الاحتفاظ بأحدث 10 كلمات فقط
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put('history', history);
  }

  // استرجاع سجل البحث
  static List<String> getSearchHistory() {
    try {
      var box = Hive.box(_boxName);
      List<dynamic>? rawList = box.get('history');
      if (rawList == null) return [];
      return rawList.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // حذف جميع الكلمات المخزنة
  static Future<void> clearSearchHistory() async {
    var box = await Hive.openBox(_boxName);
    await box.delete('history');
  }
}