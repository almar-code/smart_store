import 'package:flutter/material.dart';
import 'views/screens/main_wrapper_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainWrapperScreen(), // الشاشة التي تحتوي على الـ BottomNav
    );
  }
}