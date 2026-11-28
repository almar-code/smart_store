import 'package:hive/hive.dart';

// تخزين المقاسات المحفوظة محلياً في Hive
class SavedSizesService {
  static const String _boxName = 'user_info_box';
  static const String _key = 'saved_sizes';

  List<Map<dynamic, dynamic>> load() {
    final data = Hive.box(_boxName).get(_key);
    if (data is! List) return [];
    return data.whereType<Map>().toList();
  }

  Future<void> save(List<Map<String, dynamic>> items) async {
    await Hive.box(_boxName).put(_key, items);
  }
}
