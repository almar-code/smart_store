import 'package:flutter/material.dart';
class ItemCount extends StatelessWidget {
  final double fontSize;
  final Color color;
  const ItemCount({super.key,this.fontSize=10,this.color= Colors.red});

  @override
  Widget build(BuildContext context) {
    return  Text('3',style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w600
    ),);
  }
}
