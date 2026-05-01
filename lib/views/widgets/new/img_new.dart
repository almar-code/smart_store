import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_store/core/constants/app_colors.dart';

class cardImage extends StatelessWidget {
  final String imagePath;
  final double width;

  const cardImage({super.key, required this.imagePath, this.width = 160});

  Future<bool> _waitTimer() async {
    await Future.delayed(const Duration(seconds: 5));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _waitTimer(),
      builder: (context, snapshot) {
        // 1. أثناء الـ 5 ثواني: اعرض الوميض بنفس تصميم الصورة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor:AppColors.baseColor,
            highlightColor: AppColors.highlightColor,
            child: Container(
              width: width,
              height: 100, // يمكنك تحديد ارتفاع ثابت أو تركه يتمدد
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(20), // نفس حواف الصورة
              ),
            ),
          );
        }

        return Container(
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              height: 100,
              'assets/images/$imagePath',
              fit: BoxFit.fill,
            ),
          ),
        );
      },
    );
  }
}