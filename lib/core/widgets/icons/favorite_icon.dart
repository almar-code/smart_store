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
  final bool showBg;
  FavoriteIcon({super.key,this.color,this.size=20,this.showBg =true});
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    double finalSize = isDesktop ? size : size - 5;
    return  Padding(
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
            child: InkWell(
              child:  Icon(
                CupertinoIcons.heart,
                color:color ?? AppColors.iconColor,
                size: finalSize,
              ),
              onTap: ()=> Navigator.of(context,).push(MaterialPageRoute(builder: (context) => FavoritesScreen(screenOnly: true,))),
            ),
          ),
          Positioned(
              top: isDesktop ? 3 : 1,
              right: isDesktop ? 3 : 1,
              child:  FavoriteCount(fontSize: 8,)
          )
        ],
      ),
    );
  }
}

