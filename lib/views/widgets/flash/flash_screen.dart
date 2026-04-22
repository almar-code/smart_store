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



class Flashsubcategory extends StatelessWidget {
  const Flashsubcategory({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child:SizedBox(
        height: 80, // مهم جدًا
        child:GridView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // صفين في اللابتوب - صف في الجوال
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: isDesktop ? 80 : 55, // عرض العنصر
          ),
          itemBuilder: (context, index) {
            return Column(
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
                  width: 40,
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
}
class CategoryBarShimmer extends StatelessWidget {
  const CategoryBarShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Shimmer.fromColors(
      baseColor: AppColors.baseColor,
      highlightColor: AppColors.highlightColor,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // زر "الكل"
            _item(isDesktop),

            const SizedBox(width: 6),

            // باقي العناصر (Scrollable)
            Expanded(
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
          ],
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
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              width: isDesktop ? 125 : 100,
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
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return MasonryGridView.count(
      crossAxisCount: isDesktop ? 4 : 1,
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