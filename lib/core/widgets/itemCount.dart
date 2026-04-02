import 'package:flutter/material.dart';
class ItemCount extends StatelessWidget {
  final double fontSize;
  const ItemCount({super.key,this.fontSize=10});

  @override
  Widget build(BuildContext context) {
    return  Text('3',style: TextStyle(
      color: Colors.red,
      fontSize: fontSize,
      fontWeight: FontWeight.w600
    ),);
  }
}
