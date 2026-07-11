import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event_bus.dart';
import '../../data/models/product_model.dart';
import '../../data/repos/product_repo.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo repository;
  StreamSubscription? _subscription; // 🌟 للاستماع وإغلاق الـ Stream بأمان
  ProductCubit({required this.repository}) : super(ProductInitial()){
    // 🌟 الاستماع للمجرى المشترك بمجرد إنشاء أي نسخة من الـ Cubit
    _subscription = ProductEventBus.stream.listen((updatedProduct) {
      toggleFavoriteLocally(updatedProduct);
    });
  }

  int currentPage = 1;
  bool isFetchingMore = false;
  int? categoryID ;
  List<ProductModel> allProducts = [];
  List<ProductModel> discountProducts = []; // 🌟 مصفوفة مخصصة للخصومات المفلترة مسبقاً
  int? currentSeed; // لحفظ رقم خلطة البيانات الحالية ومنع التكرار
  int _requestId = 0;
  Future<void> fetchProducts({int? subCatId, int? categoryId, int? productId, int? similarProductId,String? date, bool isRefresh = false ,bool isDiscount = false,bool isFavorite = false}) async {
    categoryID = categoryId;
    if (isRefresh) {
      _requestId++; // إنشاء معرف جديد
      isFetchingMore = false; // مهم جداً
      currentPage = 1;
      allProducts.clear();
      discountProducts.clear(); // 🌟 تصفير الخصومات عند إعادة التحديث
      currentSeed = null; // تصفير الـ seed تماماً لطلب خلطة جديدة من لارافيل
    }
    final int currentRequest = _requestId;

    if (!isRefresh && isFetchingMore) return;

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
        isDiscount: isDiscount,
        isFavorite: isFavorite,
        customerId: 1,
        date: date,
      );
      // إذا بدأ طلب أحدث، تجاهل هذا الرد
      if (currentRequest != _requestId) return;

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
      if(similarProductId != null){
        allProducts.removeWhere((p) => p.pId == similarProductId
        );
      }
      // تحديث الحالة بالمنتجات الجديدة المدمجة بالكامل
      emit(ProductLoaded(products: List.from(allProducts), hasMore: hasMore));

      // الجلب التلقائي المتتالي للصفحات التالية حتى تنتهي البيانات بالسيرفر
      if (hasMore && currentRequest == _requestId) {
        await fetchProducts(subCatId: subCatId, categoryId: categoryId, productId: productId,date: date,isDiscount: isDiscount,isFavorite: isFavorite);
      }

    } catch (e) {
      if (currentRequest != _requestId) return;
      isFetchingMore = false;
      emit(ProductError(e.toString()));
    }
  }
  // داخل كلاس ProductCubit
  Future<void> toggleProductFavorite({required int customerId, required ProductModel product ,bool isInsideFavoritesScreen =false}) async {
    // 1. تحديد الحالة السابقة للرجوع إليها في حال الفشل
    final bool previousStatus = product.isFavorite;

    try {
      // 2. تحديث الحالة محلياً فوراً داخل مصفوفة الـ Cubit وبث الحالة الجديدة للواجهات
      product.isFavorite = !previousStatus;
      if (isInsideFavoritesScreen && !product.isFavorite) {
        allProducts.removeWhere((p) => p.pId == product.pId);
      }
      ProductEventBus.emitChanges(product);
      emit(ProductLoaded(products: List.from(allProducts), hasMore: false));

      // 3. إرسال الطلب للسيرفر عبر الـ repository
      final bool serverStatus = await repository.toggleProductFavorite(
        customerId: customerId,
        productId: product.pId,
      );

      // 4. تأكيد الحالة القادمة من السيرفر لضمان المزامنة
      if (product.isFavorite != serverStatus) {
        product.isFavorite = serverStatus;
        emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
      }
    } catch (e) {
      // 5. في حال الفشل، نراجع المنتج لحالته الأصلية ونبث الخطأ
      if (!previousStatus) {
        allProducts.add(product); // إعادة المنتج إذا حُذف بالخطأ
      }
      product.isFavorite = previousStatus;
      emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
      emit(ProductError("تعذر تحديث المفضلة: $e"));
    }
  }
  void toggleFavoriteLocally(ProductModel product) {
    // 1. نقوم بتحديث القائمة بشكل آمن عبر الـ map وتحويلها إلى القائمة الجديدة
    allProducts = allProducts.map((p) {
      if (p.pId == product.pId) {
        // نعكس قيمة الـ isFavorite للمنتج المستهدف
        p.isFavorite = product.isFavorite;
      }
      return p; // يجب إرجاع العنصر في كل الحالات
    }).toList(); // تحويلها إلى List لتنفيذ العملية فوراً
    emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
  }
}