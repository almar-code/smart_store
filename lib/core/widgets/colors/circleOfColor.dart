import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CircleOfColor extends StatelessWidget {
  final String code;
  final double width;
  final double height;
  const CircleOfColor({super.key,this.width=17,this.height=17,this.code='#000000'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: CircleAvatar(
          backgroundColor: AppColors.hexToColor(code),
        )
    );
  }
}
