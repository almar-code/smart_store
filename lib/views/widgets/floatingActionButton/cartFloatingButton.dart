import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_store/core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/itemCount.dart';
class CartFloatingButton extends StatelessWidget {
  const CartFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: FloatingActionButton(

        onPressed: () {
        },
        splashColor: Colors.transparent,
        hoverElevation: 4,
        backgroundColor:AppColors.background.withOpacity(0.9),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          // alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Icon(
                CupertinoIcons.cart,
                color:AppColors.iconColor,
                size: 20,
              ),
            ),
        Positioned(
            top: 1,
            right: 1,
            child: ItemCount())
          ],
        )
      ),
    );
  }
}