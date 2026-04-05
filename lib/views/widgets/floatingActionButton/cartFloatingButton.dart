import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/itemCount.dart';
class CartFloatingButton extends StatelessWidget {
  const CartFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
      },
      splashColor: Colors.transparent,
      hoverElevation: 4,
      backgroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Badge(
        backgroundColor: Colors.transparent,
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(bottom: 0,left: 20),
        label: ItemCount(),
        child: AppIcon(icon: CupertinoIcons.cart,size: 25,),
      )
    );
  }
}