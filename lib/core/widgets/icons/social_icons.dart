import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_store/core/constants/app_colors.dart';

import '../../constants/app_icons.dart';

class SocialIcons extends StatelessWidget {
  final bool isExpanded;
  final double padding;
  const SocialIcons({super.key,this.isExpanded = true ,this.padding = 25.0 });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal:padding),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            direction: isExpanded ? Axis.horizontal : Axis.vertical,
             spacing: isExpanded ? 24 : 19,
            children: [
              SocialIcon(
                icon: FontAwesomeIcons.whatsapp,

                color: Color(0xFF25D366),
              ),
              SocialIcon(
                icon: FontAwesomeIcons.x,

                color: AppColors.iconColor,
              ),
              SocialIcon(
                icon: FontAwesomeIcons.instagram,

                color: Color(0xFFE1306C),
              ),
              SocialIcon(
                icon: FontAwesomeIcons.facebook,

                color: Color(0xFF1877F2),
              ),

              SocialIcon(
                icon: FontAwesomeIcons.threads,

                color: AppColors.iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
