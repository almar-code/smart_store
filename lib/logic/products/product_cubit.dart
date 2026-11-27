import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/product_catalog.dart';
import '../../data/local/search_local.dart';
import '../../data/local/user_local.dart';
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
  Future<int?> _customerId() => UserLocal().getCustomerId();
  int currentPage = 1;
  bool isFetchingMore = false;
  int? categoryID ;
  List<ProductModel> allProducts = [];
  List<ProductModel> discountProducts = []; // 🌟 مصفوفة مخصصة للخصومات المفلترة مسبقاً
  int? currentSeed; // لحفظ رقم خلطة البيانات الحالية ومنع التكرار
  int _requestId = 0;

  // اخر استعلام للتحديث الصامت
  Map<String, dynamic>? _lastQuery;
  Future<void> fetchProducts({
    int? subCatId,
    int? categoryId,
    int? productId,
    int? similarProductId,
    String? date,
    String? dateFrom, // منتجات من تاريخ حتى اليوم
    String? discountFrom, // خصومات جديدة من تاريخ
    bool isRefresh = false,
    bool isDiscount = false,
    int? adsId,
    bool isFavorite = false,
    String? visualImagePath, // 🌟 المتجر الجديد للصورة الممررة للبحث البصري
    Uint8List? visualImageBytes, // صورة البحث بعد التحويل
  }) async {
    categoryID = categoryId;
    if (isRefresh) {
      // البحث البصري لا يعاد تلقائيا
      _lastQuery = (visualImageBytes != null || (visualImagePath?.isNotEmpty ?? false))
          ? null
          : {
        'subCatId': subCatId,
        'categoryId': categoryId,
        'productId': productId,
        'similarProductId': similarProductId,
        'date': date,
        'dateFrom': dateFrom,
        'discountFrom': discountFrom,
        'isDiscount': isDiscount,
        'adsId': adsId,
        'isFavorite': isFavorite,
      };
      _requestId++;
      isFetchingMore = false;
      currentPage = 1;
      allProducts.clear();
      discountProducts.clear();
      currentSeed = null;
    }
    final int currentRequest = _requestId;

    if (!isRefresh && isFetchingMore) return;

    if (currentPage == 1) {
      emit(ProductLoading());
    } else {
      isFetchingMore = true;
      emit(ProductLoaded(products: List.from(allProducts), hasMore: true));
    }

    try {
      // 🌟 التحقق: إذا كانت هناك صورة للبحث البصري، نستدعي دالة البحث البصري، وإلا نستدعي الدالة العادية
      final Map<String, dynamic> result;

      if (visualImageBytes != null || (visualImagePath != null && visualImagePath.isNotEmpty)) {
        result = await repository.getVisualSearchProducts(
          imagePathOrUrl: visualImagePath ?? '',
          imageBytes: visualImageBytes,
          page: currentPage,
          seed: currentSeed,
        );
      } else {
        result = await repository.fetchProductsPaginated(
          subCatId: subCatId,
          categoryId: categoryId,
          productId: productId,
          seed: currentSeed,
          page: currentPage,
          isDiscount: isDiscount,
          adsId: adsId,
          isFavorite: isFavorite,
          customerId:  await _customerId(),
          date: date,
          dateFrom: dateFrom,
          discountFrom: discountFrom,
        );
      }

      final List<ProductModel> newProducts = result['products'];
      final bool hasMore = result['hasMore'];

      if (currentPage == 1 && result['seed'] != null) {
        currentSeed = result['seed'];
      }

      allProducts.addAll(newProducts);
      // حفظ المنتجات في الكتالوج المحلي
      ProductCatalog.instance.absorb(newProducts);
      final List<ProductModel> newDiscounts = newProducts.where((p) => p.discount != null).toList();
      discountProducts.addAll(newDiscounts);
      currentPage++;
      isFetchingMore = false;

      if (similarProductId != null) {
        allProducts.removeWhere((p) => p.pId == similarProductId);
      }

      emit(ProductLoaded(products: List.from(allProducts), hasMore: hasMore));

      if (hasMore && currentRequest == _requestId) {
        await fetchProducts(
          subCatId: subCatId,
          categoryId: categoryId,
          productId: productId,
          date: date,
          dateFrom: dateFrom,
          discountFrom: discountFrom,
          isDiscount: isDiscount,
          adsId: adsId,
          isFavorite: isFavorite,
          visualImagePath: visualImagePath,
        );
      }
    } catch (e) {
      if (currentRequest != _requestId) return;
      isFetchingMore = false;
      emit(ProductError(e.toString()));
    }
  }
  /// فتح المنتج ومنتجات فئته من الكتالوج المحلي بدون طلب للسيرفر
  /// ترجع false اذا لم يوجد المنتج محليا ليتم الجلب من السيرفر
  bool loadFromCatalog({required int productId, int? subCatId}) {
    final list = ProductCatalog.instance.related(productId: productId, subCatId: subCatId);
    if (list.isEmpty) return false;

    _requestId++;
    isFetchingMore = false;
    currentPage = 1;
    allProducts = List.of(list);
    discountProducts = list.where((p) => p.discount != null).toList();
    _lastQuery = {'subCatId': subCatId ?? list.first.subCatId, 'productId': productId};
    emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
    return true;
  }

  /// اعادة الجلب بالخلفية بدون شاشة تحميل
  Future<void> refreshSilently() async {
    final q = _lastQuery;
    if (q == null || isClosed) return;
    final int request = ++_requestId;
    final List<ProductModel> fresh = [];
    int page = 1;
    int? seed;

    try {
      bool hasMore = true;
      while (hasMore) {
        final result = await repository.fetchProductsPaginated(
          subCatId: q['subCatId'],
          categoryId: q['categoryId'],
          productId: q['productId'],
          seed: seed,
          page: page,
          isDiscount: q['isDiscount'] ?? false,
          adsId: q['adsId'],
          isFavorite: q['isFavorite'] ?? false,
          customerId: await _customerId(),
          date: q['date'],
          dateFrom: q['dateFrom'],
          discountFrom: q['discountFrom'],
        );
        // تم طلب جديد اثناء التحديث فنلغي هذا
        if (request != _requestId || isClosed) return;
        fresh.addAll(result['products'] as List<ProductModel>);
        hasMore = result['hasMore'] == true;
        seed ??= result['seed'];
        page++;
      }
    } catch (_) {
      return; // الفشل الصامت يبقي البيانات الحالية
    }

    if (q['similarProductId'] != null) {
      fresh.removeWhere((p) => p.pId == q['similarProductId']);
    }
    ProductCatalog.instance.absorb(fresh);
    allProducts = fresh;
    discountProducts = fresh.where((p) => p.discount != null).toList();
    emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
  }

  // داخل كلاس ProductCubit
  Future<void> toggleProductFavorite({required ProductModel product ,bool isInsideFavoritesScreen =false}) async {
    // 1. تحديد الحالة السابقة للرجوع إليها في حال الفشل
    final bool previousStatus = product.isFavorite;

    try {
      // 2. تحديث الحالة محلياً فوراً داخل مصفوفة الـ Cubit وبث الحالة الجديدة للواجهات
      product.isFavorite = !previousStatus;
      ProductCatalog.instance.setFavorite(product.pId, product.isFavorite);
      if (isInsideFavoritesScreen && !product.isFavorite) {
        allProducts.removeWhere((p) => p.pId == product.pId);
      }
      ProductEventBus.emitChanges(product);
      emit(ProductLoaded(products: List.from(allProducts), hasMore: false));

      // 3. إرسال الطلب للسيرفر عبر الـ repository
      final bool serverStatus = await repository.toggleProductFavorite(
        customerId:  await _customerId(),
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
    if (isClosed) return;
    allProducts = allProducts.map((p) {
      if (p.pId == product.pId) {
        // نعكس قيمة الـ isFavorite للمنتج المستهدف
        p.isFavorite = product.isFavorite;
      }
      return p; // يجب إرجاع العنصر في كل الحالات
    }).toList(); // تحويلها إلى List لتنفيذ العملية فوراً
    ProductCatalog.instance.setFavorite(product.pId, product.isFavorite);
    emit(ProductLoaded(products: List.from(allProducts), hasMore: false));
  }
  // إيقاف الاستماع عند إغلاق الشاشة
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}