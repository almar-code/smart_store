import 'dart:async';
import '../../data/models/product_model.dart';

class ProductEventBus {
  static final StreamController<ProductModel> _controller = StreamController<ProductModel>.broadcast();
  static Stream<ProductModel> get stream => _controller.stream;
  // 🌟 العداد الرقمي الكلي المخزن في الذاكرة
  static int favoriteCount = 0;

  // دالة لتحديث العداد يدويًا عند إقلاع التطبيق من لارافيل
  static void setInitialCount(int count) {
    favoriteCount = count;
  }

  // عند الضغط على زر الآيك، نزيد أو ننقص العداد مباشرة
  static void emitChanges(ProductModel updatedProduct) {
    if (updatedProduct.isFavorite) {
      favoriteCount++;
    } else {
      if (favoriteCount > 0) favoriteCount--;
    }
    _controller.add(updatedProduct);
  }
}