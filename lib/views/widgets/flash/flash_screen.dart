import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';


class Flasheds extends StatelessWidget {
  const Flasheds({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: Container(
        height: isDesktop ? 185 : 160,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
class FlashProducts extends StatelessWidget {
  const FlashProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // حساب حجم الشاشة لتحديد عدد الأعمدة كما هو في كود المنتجات الخاص بك تماماً
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    bool isIpad = MediaQuery.of(context).size.width < 900 && MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 6 : isIpad ? 4 : 2;

    // مصفوفة تحتوي على أطوال مختلفة لمحاكاة الأطوال المتفاوتة للكروت في الـ Masonry
    final List<double> randomHeights = [240, 210, 220, 260, 230, 240];

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: MasonryGridView.count(
        scrollDirection: Axis.vertical,
        crossAxisCount: itemCount,
        mainAxisSpacing: 15,  // نفس المسافات الأصلية لكودك
        crossAxisSpacing: 12, // نفس المسافات الأصلية لكودك
        shrinkWrap: true,
        itemCount: 20, // تحديد عدد العناصر المطلوبة (20 منتج وهمي)
        physics: const NeverScrollableScrollPhysics(), // متوافق مع كود الواجهة الأب
        itemBuilder: (context, index) {
          // جلب طول مختلف لكل عنصر بناءً على الاندكس بشكل دوري
          double currentHeight = randomHeights[index % randomHeights.length];

          return Container(
            height: currentHeight,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(7), // نفس حواف الكارد الحقيقي حقك تماماً
            ),
          );
        },
      ),
    );
  }
}


class Flashsubcategory extends StatelessWidget {
  const Flashsubcategory({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: SizedBox(
        height: isDesktop ? 83 : 70, // 🌟 جعلناه مطابقاً تماماً لارتفاع الـ SubcategoryBar الأصلي لعدم حدوث قفزة في الواجهة
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 2), // مطابق للأصلي
          itemCount: 30, // 10 عناصر كافية جداً لشغل الشاشة أثناء التحميل
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: isDesktop ? 80 : 55,
          ),
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min, // 🌟 إجبار العمود على أخذ مساحة عناصره فقط دون تمدد
              children: [
                Container(
                  width: isDesktop ? 55 : 45,
                  height: isDesktop ? 55 : 45,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: isDesktop ? 50 : 35, // عرض متناسق مع حجم الصورة الوهمية
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}class CategoryBarShimmer extends StatelessWidget {
  const CategoryBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: 40,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              return _item(isDesktop);
            },
          ),
        ),
      ),
    );
  }

  Widget _item(bool isDesktop) {
    return Container(
      width: isDesktop ? 60 : 45,
      height: 17,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class DiscountsShimmer extends StatelessWidget {
  const DiscountsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SizedBox(
      height: isDesktop ? 170 : 155,
      child: Shimmer.fromColors(
        baseColor: AppColors.baseColor,
        highlightColor: AppColors.highlightColor,
        child: MasonryGridView.count(
          scrollDirection: Axis.vertical,
          crossAxisCount:isDesktop ? 6 : 3,
          mainAxisSpacing: 10, //مسافة بين العنصر والذي تحتة
          crossAxisSpacing: 10, //مسافة بين العنصر والذي جنبة
          shrinkWrap: true, //حجم حسب الاب
          itemCount:9,
          physics: NeverScrollableScrollPhysics(), //توقيف الشريط
          itemBuilder: (context, index) {
            return Container(
              width: isDesktop ? 115 :100,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                children: [

                  // 🔲 صورة المنتج (Skeleton)
                  Container(
                    height: isDesktop ? 130 : 120,
                    decoration:  BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 💰 السعر (Skeleton)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _priceBox(width: 30),
                      const SizedBox(width: 6),
                      _priceBox(width: 25),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _priceBox({required double width}) {
    return Container(
      width: width,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


class MasonryGridShimmer extends StatelessWidget {
  const MasonryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 1000;
    bool isIpad = MediaQuery.of(context).size.width < 1000 &&  MediaQuery.of(context).size.width > 450;
    int itemCount = isDesktop ? 3 : isIpad ? 2 : 1;
    return MasonryGridView.count(
      crossAxisCount: itemCount,
      mainAxisSpacing: 15,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.baseColor,
          highlightColor: AppColors.highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Stack(
              children: [
                Row(
                  children: [

                    /// 🖼️ صورة
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),

                    /// 📄 النصوص
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _line(width: 80, height: 10),

                            const SizedBox(height: 8),

                            _line(width: 60, height: 8),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                _line(width: 40, height: 8),
                                const SizedBox(width: 6),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            _line(width: 50, height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /// 🔢 زر الكمية
                PositionedDirectional(
                  bottom: 15,
                  end: 15,
                  child: Container(
                    height: 32,
                    width: 90,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _line({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


class NewInShimmer extends StatelessWidget {
  const NewInShimmer({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppColors.ContainerColor,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.baseColor,
        highlightColor: AppColors.highlightColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6, // عدد افتراضي أثناء التحميل
          itemBuilder: (context, index) => Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoLoadingShimmer extends StatelessWidget {
  const VideoLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFF2A2A2A),
      highlightColor: Color(0xFF3A3A3A) ,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color:  Color(0xFF2A2A2A),
      ),
    );
  }
}

class FlashSubcategoryDrawer extends StatelessWidget {
  const FlashSubcategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: ListView.builder(
        // إيقاف التمرير الداخلي لكي لا يتعارض مع تمرير الـ Drawer الأساسي
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10, // عرض 10 عناصر وميض كما طلبت
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Row(
                  children: [
                    // 1. وميض الـ CircleAvatar (الدارة الرمزية)
                    Container(
                      width: 40, // يعادل radius: 20
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16), // المسافة الافتراضية للـ ListTile

                    // 2. وميض النص (Title)
                    Expanded(
                      child: Container(
                        height: 12, // متناسق مع حجم الخط 10 الحقيقي
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 3. وميض السهم (Trailing Icon)
                    Container(
                      width: 14, // نفس حجم الـ size: 14 الحقيقي للسهم
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. خط الـ Divider المتطابق تماماً مع تصميمك
              const Divider(
                indent: 10,
                endIndent: 10,
                thickness: 0.5,
              ),
            ],
          );
        },
      ),
    );
  }
}