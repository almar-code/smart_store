import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../views/screens/cart/cart_screen.dart';
import '../../constants/app_colors.dart';
import '../itemCount.dart';
class CartIcon extends StatelessWidget {
  final Color? color;
  final double size;
  final bool showBg;
  CartIcon({super.key,this.color,this.size=19,this.showBg =true});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double finalSize = isDesktop ? size : size - 5;
    return  InkWell(
      onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => CartScreen(screenOnly: true,))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 5 : 4),
        child: Stack(
          children: [
            Container(
              width: isDesktop ? 35 : 30,
              height: isDesktop ? 35 : 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: showBg ? AppColors.backgroundSecondary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.cart,
                color:color ?? AppColors.iconColor,
                size: finalSize,
              ),
            ),
            Positioned(
                top: isDesktop ? 1 : 0,
                right: isDesktop ? 1 : 0,
                child:  ItemCount(fontSize: 9,)
            )
          ],
        ),
      ),
    );
  }
}

