import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

class CircularProgress extends StatelessWidget {
  final double size;
  const CircularProgress({
    super.key,
    this.size = 25.0,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitDualRing(
        color: AppColors.primary,
        size: size,
        lineWidth: 3.0, // لجعل الدائرة نحيفة وأنيقة مثل سناب
      ),
    );
  }
}