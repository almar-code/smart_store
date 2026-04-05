import 'package:flutter/material.dart';
class Logo extends StatelessWidget {
  final double width;
  final double height;
  Logo({super.key,this.width=27,this.height=27});
  @override
  Widget build(BuildContext context) {
    return  Image.asset(
      'assets/images/logo.png',
      width: width ,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
