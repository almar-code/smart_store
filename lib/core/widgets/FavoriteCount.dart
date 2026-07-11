import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../logic/products/product_cubit.dart';
import '../../logic/products/product_event_bus.dart';
import '../constants/app_colors.dart';
class FavoriteCount extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const FavoriteCount({super.key, this.fontSize = 10, this.color});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProductModel>(
      stream: ProductEventBus.stream,
      builder: (context, snapshot) {
        // 🚀 قراءة العدد الثابت الكلي المحدث تلقائياً من لارافيل أو من كبسة الزر
        final int currentCount = ProductEventBus.favoriteCount;

        return Text(
          '${currentCount != 0 ? currentCount : "" }',
          style: TextStyle(
              color: color ?? AppColors.primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w600),
        );
      },
    );
  }
}