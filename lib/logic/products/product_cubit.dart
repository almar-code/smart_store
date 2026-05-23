// cubit/product_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/repos/product_repo.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo repository;

  ProductCubit({required this.repository}) : super(ProductInitial());

  int currentPage = 1;
  bool isFetchingMore = false;
  int? categoryID ;
  List<ProductModel> allProducts = [];
  List<ProductModel> discountProducts = []; // 🌟 مصفوفة مخصصة للخصومات المفلترة مسبقاً
  int? currentSeed; // لحفظ رقم خلطة البيانات الحالية ومنع التكرار

  Future<void> fetchProducts({int? subCatId, int? categoryId, int? productId, bool isRefresh = false ,bool isDiscount = false}) async {
    categoryID = categoryId;
    if (isRefresh) {
      currentPage = 1;
      allProducts.clear();
      discountProducts.clear(); // 🌟 تصفير الخصومات عند إعادة التحديث
      currentSeed = null; // تصفير الـ seed تماماً لطلب خلطة جديدة من لارافيل
    }

    if (isFetchingMore) return;

    if (currentPage == 1) {
      emit(ProductLoading());
    } else {
      isFetchingMore = true;
      // 🌟 بث الحالة الحالية ليعلم الـ context.select بالواجهة أن هناك جلب مستمر (isFetchingMore = true)
      emit(ProductLoaded(products: List.from(allProducts), hasMore: true));
    }

    try {
      // تمرير المعاملات كاملة وبدقة إلى الـ repository
      final result = await repository.fetchProductsPaginated(
        subCatId: subCatId,
        categoryId: categoryId,
        productId: productId, // 🌟 تمرير آيدي المنتج للتثبيت بالصدارة
        seed: currentSeed,
        page: currentPage,
        isDiscount: isDiscount
      );

      final List<ProductModel> newProducts = result['products'];
      final bool hasMore = result['hasMore'];

      // استقبال الـ seed المولد من لارافيل وحفظه إذا كانت الصفحة الأولى لضمان التثبيت
      if (currentPage == 1 && result['seed'] != null) {
        currentSeed = result['seed'];
      }

      // 1. دمج المنتجات الجديدة في المصفوفة العامة
      allProducts.addAll(newProducts);

      // 2. 🌟 الفلترة الفورية: استخراج المنتجات ذات الخصومات الفعالة من الدفعة الحالية وإضافتها
      final List<ProductModel> newDiscounts = newProducts.where((p) => p.discount != null).toList();
      discountProducts.addAll(newDiscounts);

      currentPage++;
      isFetchingMore = false;

      // تحديث الحالة بالمنتجات الجديدة المدمجة بالكامل
      emit(ProductLoaded(products: List.from(allProducts), hasMore: hasMore));

      // الجلب التلقائي المتتالي للصفحات التالية حتى تنتهي البيانات بالسيرفر
      if (hasMore) {
        fetchProducts(subCatId: subCatId, categoryId: categoryId, productId: productId,isDiscount: isDiscount);
      }

    } catch (e) {
      isFetchingMore = false;
      emit(ProductError(e.toString()));
    }
  }
}