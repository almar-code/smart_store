import 'package:flutter/material.dart';

class App_Logo extends StatelessWidget {
  final double width;
  final double height;
  App_Logo({super.key,this.width=30,this.height=30});
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
