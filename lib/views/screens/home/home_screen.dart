import 'package:flutter/material.dart';
import 'package:smart_store/core/widgets/app_bar/app_search.dart';
import 'package:smart_store/core/widgets/app_bar/app_title.dart';
import 'package:smart_store/core/widgets/app_bar/app_logo.dart';
import 'package:smart_store/core/widgets/app_bar/app_icon_bar.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery هنا يضمن تحديث الواجهة فوراً عند تصغير المتصفح
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: isDesktop
            ?  Text('home'.tr(),style: TextStyle(fontSize: 15),): Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            App_Logo(),
            const SizedBox(width: 8),
            App_Title(),
          ],
        ),

        actions: [
          if (isDesktop)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: App_Search(widthFactor:0.3),
            ),

          AppIconBar(icon: CupertinoIcons.bell),
          AppIconBar(icon: CupertinoIcons.mail),
          SizedBox(width: 10),
        ],
      ),
      body: const Center(
        child: Text("Home Page"),
      ),
    );
  }
}