import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class App_Search extends StatelessWidget {
  final double widthFactor;

  const App_Search({super.key, this.widthFactor = 0.4});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(13),
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
                style:  TextStyle(fontSize: 12, color: Colors.black),
                decoration: InputDecoration(
                  hintText: tr('searchHere'),
                  hintStyle: const TextStyle(color: AppColors.iconColor, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onTap: () {

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
