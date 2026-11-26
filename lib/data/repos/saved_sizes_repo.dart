import '../models/saved_size_model.dart';
import '../services/saved_sizes_service.dart';

class SavedSizesRepo {
  final SavedSizesService service;
  SavedSizesRepo(this.service);

  // الأحدث أولاً
  List<SavedSizeModel> getAll() {
    final list = service.load().map(SavedSizeModel.fromMap).toList();
    list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return list;
  }

  Future<List<SavedSizeModel>> add(SavedSizeModel size) => _write([size, ...getAll()]);

  Future<List<SavedSizeModel>> rename(String id, String name) =>
      _write(getAll().map((s) => s.id == id ? s.copyWith(name: name) : s).toList());

  Future<List<SavedSizeModel>> delete(String id) => _write(getAll().where((s) => s.id != id).toList());

  Future<List<SavedSizeModel>> _write(List<SavedSizeModel> items) async {
    await service.save(items.map((s) => s.toMap()).toList());
    return items;
  }
}
