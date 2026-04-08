import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../views/screens/cart/cart_screen.dart';
import '../../../views/screens/favorites/favorites_screen.dart';
import '../../constants/app_colors.dart';
import '../FavoriteCount.dart';
import '../itemCount.dart';
class FavoriteIcon extends StatelessWidget {
  final Color? color;
  final double size;
  FavoriteIcon({super.key,this.color,this.size=20});
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
                CupertinoIcons.heart,
                color:color ?? AppColors.iconColor,
                size: finalSize,
              ),
              onPressed: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true,))),
            ),
            Positioned(
                top: 1,
                right: 1,
                child:  FavoriteCount(fontSize: 9,)
            )
          ],
        ),
      ),
    );
  }
}

