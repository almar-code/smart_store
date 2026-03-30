import 'package:flutter/material.dart';
import 'views/screens/main_wrapper_screen.dart';
import 'package:easy_localization/easy_localization.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: MainWrapperScreen(), // الشاشة التي تحتوي على الـ BottomNav
    );
  }
}