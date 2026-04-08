import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../views/screens/cart/cart_screen.dart';
import '../../constants/app_colors.dart';
import '../itemCount.dart';
class CartIcon extends StatelessWidget {
  final Color? color;
  final double size;
  CartIcon({super.key,this.color,this.size=20});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double finalSize = isDesktop ? size : size - 5;
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 6 : 4),
      child: Container(
        width: isDesktop ? 40 : 30,
        height: isDesktop ? 40 : 30,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            IconButton(
              icon:  Icon(
                CupertinoIcons.cart,
                color:color ?? AppColors.iconColor,
                size: finalSize,
              ),
              onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => CartScreen(screenOnly: true,))),
            ),
            Positioned(
              top: 1,
                right: 1,
                child:  ItemCount(fontSize: 9,)
            )
          ],
        ),
      ),
    );
  }
}

