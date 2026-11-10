import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadow.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../core/widgets/icons/arrow_back_icon.dart';
import '../../../core/widgets/search/app_search.dart';
import '../../../core/widgets/buttons/smart_floating_button.dart';
import '../../../core/widgets/titleBar.dart';
import '../../../logic/products/product_cubit.dart';
import '../../../logic/products/product_state.dart';
import '../../../logic/search/search_cubit.dart';
import '../../widgets/floatingActionButton/cartFloatingButton.dart';
import '../../widgets/product/all_products.dart';
import '../../../data/local/search_local.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> historyList = [];
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  void _selectQuery(SearchCubit cubit, String selectedText) {
    cubit.performGlobalSearch(selectedText);
    _loadHistory();
    _searchController.text = selectedText; // تحديث النص في شريط البحث فوراً
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: selectedText.length), // وضع المؤشر في نهاية الكلمة
    );

  }
  void _loadHistory() {
    setState(() {
      historyList = SearchLocal.getSearchHistory();
    });
  }
  @override
  void dispose() {
    _searchController.dispose(); // 🌟 تنظيف الـ Controller عند الخروج
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (context) => di.sl<SearchCubit>()..fetchAllProductsWithoutConditions(),
),
    BlocProvider(
      create: (context) => di.sl<ProductCubit>(),
    ),
  ],
  child: SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 0,
          titleSpacing: 3,
          title:  App_Search(widthFactor: 1, isSearchScreen: true,controller: _searchController,),
          actions: [ArrowBack()],
        ),
        body: BlocBuilder<SearchCubit, ProductState>(
          builder: (context, state) {
            final cubit = context.read<SearchCubit>();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. عرض الاقتراحات المنسدلة (إن وجدت أثناء الكتابة)
                    if (cubit.searchSuggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppShadow.commonShadow,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cubit.searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = cubit.searchSuggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(CupertinoIcons.search, size: 16),
                              title: Text(suggestion),
                              onTap: () {
                                _selectQuery(cubit, suggestion);
                              },
                            );
                          },
                        ),
                      ),

                    // 2. شريط سجل البحث (سلة الحذف والكلمات المخزنة)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TitleBar(title: tr('searchHistory'),viewMoreShow: InkWell(
                        onTap: () async {
                          await SearchLocal.clearSearchHistory();
                          _loadHistory();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            CupertinoIcons.delete,
                            color: AppColors.iconColor,
                            size: 15,
                          ),
                        ),
                      ),),
                    ),
                    const SizedBox(height: 10),

                    // عرض الكلمات المخزنة محلياً في Wrap
                    Wrap(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: historyList.map((item) {
                        return InkWell(
                          onTap: () {
                            _selectQuery(cubit, item);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: _buildCategoryItem(item),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // 3. إظهار TitleBar و AllProducts فقط بعد إتمام البحث
                    if (cubit.hasSearched) ...[
                      TitleBar(title: tr('SearchResults')),
                      const SizedBox(height: 10),
                      const AllProducts(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 10,
          children: [
            SmartFloatingButton(),
            CartFloatingButton(),
          ],
        ),
      ),
    ),
);
  }

  Widget _buildCategoryItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(5),
        boxShadow: AppShadow.commonShadow,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
    );
  }
}