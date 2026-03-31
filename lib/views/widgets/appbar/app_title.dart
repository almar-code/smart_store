import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';

class DynamicAppTitle extends StatelessWidget {
  final int currentIndex;

  const DynamicAppTitle({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    String firstPart = "";
    String secondPart = "";

    switch (currentIndex) {
      case 1:
        firstPart = "new".tr();
        secondPart = " NICE";
        break;
      case 3:
        firstPart = "cart".tr();
        secondPart = "shopping".tr();
        break;
      default:
        firstPart = "";
        secondPart = "home".tr();
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstPart,
            style: const TextStyle(
              color: Color(0xFF03C2A9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: secondPart,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class CustomSearchBar extends StatelessWidget {
  final double widthFactor; // للتحكم في عرض الشريط (مثلاً 0.2 للابتوب و 0.7 للجوال)

  const CustomSearchBar({super.key, this.widthFactor = 0.4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(CupertinoIcons.search, color: Colors.black54, size: 18),
                SizedBox(width: 8),
                Icon(CupertinoIcons.camera, color: Colors.black54, size: 18),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'search here...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onTap: () {
                  // منطق الانتقال لصفحة البحث
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}