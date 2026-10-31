import 'dart:async';
import '../../core/utils/search_service.dart';
import '../../data/local/search_local.dart';
import '../../data/models/product_model.dart';
import '../products/product_cubit.dart';
import '../products/product_state.dart';

class SearchCubit extends ProductCubit {
  SearchCubit({required super.repository});

  List<ProductModel> allUnfilteredProducts = [];
  List<String> searchSuggestions = [];
  List<ProductModel> searchResults = [];
  bool hasSearched = false;
  Timer? _searchDebounce;

  // 1. جلب كافة المنتجات للبحث بدون شروط
  Future<void> fetchAllProductsWithoutConditions() async {
    emit(AllProductsUnfilteredLoading());
    try {
      allUnfilteredProducts = await repository.fetchAllProductsUnfiltered();
      emit(AllProductsUnfilteredLoaded(products: List.from(allUnfilteredProducts)));
    } catch (e) {
      emit(AllProductsUnfilteredError(e.toString()));
    }
  }

  // 2. اقتراحات البحث أثناء الكتابة (تشمل الأسماء، والأقسام، والألوان)
  void onSearchTextChanged(String query) {
    _searchDebounce?.cancel();

    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      searchSuggestions = [];
      hasSearched = false;
      searchResults = [];
      allProducts = [];
      emit(ProductLoaded(products: const [], hasMore: false));
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      Set<String> suggestions = {};

      for (var p in allUnfilteredProducts) {
        if (SearchService.isFuzzyMatch(p.pName, cleanQuery)) suggestions.add(p.pName);
        if (p.pNameEn != null && SearchService.isFuzzyMatch(p.pNameEn!, cleanQuery)) {
          suggestions.add(p.pNameEn!);
        }

        if (p.subcategory != null && SearchService.isFuzzyMatch(p.subcategory!.subcatName, cleanQuery)) {
          suggestions.add(p.subcategory!.subcatName);
        }
        if (p.category != null && SearchService.isFuzzyMatch(p.category!.name, cleanQuery)) {
          suggestions.add(p.category!.name);
        }

        for (var color in p.colors) {
          if (SearchService.isFuzzyMatch(color.colorName, cleanQuery)) {
            suggestions.add(color.colorName);
          }
        }

        if (suggestions.length >= 6) break;
      }

      searchSuggestions = suggestions.take(6).toList();
      emit(ProductLoaded(products: List.from(searchResults), hasMore: false));
    });
  }

  // 3. تنفيذ البحث الشامل (يبحث في كل تفاصيل المنتج بدقة فائقة)
  Future<void> performGlobalSearch(String query) async {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      hasSearched = false;
      searchResults = [];
      allProducts = [];
      emit(ProductLoaded(products: const [], hasMore: false));
      return;
    }

    hasSearched = true;
    emit(ProductLoading());
    searchSuggestions = [];

    await SearchLocal.saveSearchQuery(query.trim());

    searchResults = allUnfilteredProducts.where((p) {
      // أ) الاسم والوصف (عربي وإنجليزي)
      bool matchName = SearchService.isFuzzyMatch(p.pName, cleanQuery) ||
          (p.pNameEn != null && SearchService.isFuzzyMatch(p.pNameEn!, cleanQuery));

      bool matchDesc = (p.pDescription != null && SearchService.isFuzzyMatch(p.pDescription!, cleanQuery)) ||
          (p.pDescriptionEn != null && SearchService.isFuzzyMatch(p.pDescriptionEn!, cleanQuery));

      // ب) السعر
      bool matchPrice = p.pPrice.toString().contains(cleanQuery);

      // ج) الأقسام الفرعية والرئيسية
      bool matchSubCat = (p.subcategory != null && SearchService.isFuzzyMatch(p.subcategory!.subcatName, cleanQuery)) ||
          (p.subcategory?.subcatNameEn != null && SearchService.isFuzzyMatch(p.subcategory!.subcatNameEn!, cleanQuery));

      bool matchCat = (p.category != null && SearchService.isFuzzyMatch(p.category!.name, cleanQuery)) ||
          (p.category?.nameEn != null && SearchService.isFuzzyMatch(p.category!.nameEn!, cleanQuery));

      // د) الألوان
      bool matchColor = p.colors.any((c) =>
      SearchService.isFuzzyMatch(c.colorName, cleanQuery) ||
          (c.colorNameEn != null && SearchService.isFuzzyMatch(c.colorNameEn!, cleanQuery)) ||
          (c.colorCode?.toLowerCase().contains(cleanQuery) ?? false));

      // هـ) المقاسات
      bool matchSize = p.sizes.any((s) => SearchService.isFuzzyMatch(s.sizeName, cleanQuery));

      // و) الخصومات
      bool matchDiscount = p.discount != null &&
          (p.discount!.discountPerce.toString().contains(cleanQuery) ||
              (p.discount!.endDate != null && SearchService.isFuzzyMatch(p.discount!.endDate!, cleanQuery)));

      // ز) الإعلانات العامة
      bool matchAds = p.generalAdvertisements.any((ad) => SearchService.isFuzzyMatch(ad.adsName, cleanQuery));

      // البحث يشمل كل الحقول بدون استثناء
      return matchName || matchDesc || matchPrice || matchSubCat || matchCat || matchColor || matchSize || matchDiscount || matchAds;
    }).toList();

    // تحديث القائمة الموروثة لكي تعرضها واجهة AllProducts فوراً
    allProducts = List.from(searchResults);
    emit(ProductLoaded(products: List.from(searchResults), hasMore: false));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}