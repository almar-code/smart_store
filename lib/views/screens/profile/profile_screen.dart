import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/circleImage/circle_image.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/user_profile.dart';
import '../../widgets/profile/profile_list.dart';
import 'package:easy_localization/easy_localization.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;
    context.locale;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 5,
        title: UserProfile(),
        actions: [
            AppIcon(icon:  AppColors.isDark.value ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,onPressed: (){
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },),
          AppIcon(icon: CupertinoIcons.person_crop_circle_badge_xmark),
          SizedBox(width: 10),
        ],
      ),
      body: ProfileList(),
    );
  }
}
