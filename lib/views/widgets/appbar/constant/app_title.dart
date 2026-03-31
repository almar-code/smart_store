import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_colors.dart';

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
              color: AppColors.primary,
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


