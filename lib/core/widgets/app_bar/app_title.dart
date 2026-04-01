import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class App_Title extends StatelessWidget {
  final String firstPart ;
  final String secondPart;

  App_Title({super.key,this.firstPart="N",this.secondPart="ICE"});

  @override
  Widget build(BuildContext context) {

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstPart,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: secondPart,
            style: const TextStyle(
              color: AppColors.iconColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}




