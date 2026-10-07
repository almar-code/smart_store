import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

class CircularProgress extends StatelessWidget {
  final double size;
  final Color? color; // إضافة برامتر اللون

  const CircularProgress({
    super.key,
    this.size = 25.0,
    this.color, // اختياري
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitDualRing(
        color: color ?? AppColors.primary, // القيمة الافتراضية AppColors.primary
        size: size,
        lineWidth: 3.0,
      ),
    );
  }
}