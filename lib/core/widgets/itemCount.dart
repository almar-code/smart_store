import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_store/logic/cart/cart_cubit.dart';
class ItemCount extends StatelessWidget {
  final double fontSize;
  final Color color;
  const ItemCount({super.key,this.fontSize=10,this.color= Colors.red});

  @override
  Widget build(BuildContext context) {
    int itemCount = context.watch<CartCubit>().allProducts.length;
    return  Text(itemCount > 0? '$itemCount' : "",style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600
    ),);
  }
}
