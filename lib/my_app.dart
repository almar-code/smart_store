import 'package:flutter/material.dart';
import 'views/screens/main_wrapper_screen.dart';
import 'package:easy_localization/easy_localization.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // key: ValueKey(context.locale), // مهم لإعادة البناء عند تغيير اللغة
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: MainWrapperScreen(),
    );
  }
}