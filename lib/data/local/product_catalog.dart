import 'dart:collection';
import '../models/product_model.dart';

// نسخة محلية من كل المنتجات التي وصلت من السيرفر
// نستخدمها لفتح صفحة المنتجات فورا بدون طلب جديد
class ProductCatalog {
  ProductCatalog._();
  static final ProductCatalog instance = ProductCatalog._();

  final LinkedHashMap<int, ProductModel> _byId = LinkedHashMap();

  bool get isEmpty => _byId.isEmpty;
  ProductModel? byId(int id) => _byId[id];

  // اضافة او تحديث منتجات
  void absorb(Iterable<ProductModel> products) {
    for (final p in products) {
      _byId[p.pId] = p;
    }
  }

  // استبدال الكتالوج كاملا بعد التحديث الدوري
  void replaceAll(Iterable<ProductModel> products) {
    _byId.clear();
    absorb(products);
  }

  // تحديث حالة المفضلة
  void setFavorite(int productId, bool value) {
    _byId[productId]?.isFavorite = value;
  }

  // المنتج المختار اولا ثم بقية منتجات نفس الفئة
  List<ProductModel> related({required int productId, int? subCatId}) {
    final pinned = _byId[productId];
    final sub = subCatId ?? pinned?.subCatId;
    if (pinned == null || sub == null) return const [];

    final others = _byId.values.where((p) => p.subCatId == sub && p.pId != productId);
    return [pinned, ...others];
  }
}
