import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/widgets/show_loading.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/theme_icon.dart';
import '../../../core/widgets/network_service.dart';
import '../../../core/widgets/user_profile.dart';
import '../../../data/local/user_local.dart';
import '../../../data/repos/auth_repo.dart';
import '../../../data/services/auth_service.dart';
import '../../../logic/login/login_cubit.dart';
import '../../../logic/login/profile_logic.dart';
import '../../../logic/navigation/navigation_cubit.dart';
import '../../widgets/login/add_phone_number.dart';
import '../../widgets/profile/profile_list.dart';
import 'package:easy_localization/easy_localization.dart';


class ProfileScreen extends StatelessWidget {
 const  ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {

    bool isDesktop = MediaQuery.of(context).size.width > 800;
    context.locale;
    return  BlocBuilder<LoginCubit, bool>(
      builder: (context, state){

        final box = Hive.box('user_info_box');

        String? phone = box.get('phone');

        bool hasNoPhone = (phone == null || phone.isEmpty);
      return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.background,
            titleSpacing: 5,
            title: UserProfile(),
            actions: [
              ThemeIcon(),
              InkWell(
                onTap:() => _showLogoutDialog(context),
                  child: AppIcon(icon: CupertinoIcons.person_crop_circle_badge_xmark)),
              SizedBox(width: 10),
            ],
          ),
          body: Column(
            children: [
              if(hasNoPhone && state ) ...[
                  AddPhoneNumber(),
               ],
              Expanded(child: ProfileList()),
            ],
          ),
        );
      }
    );
  }

}

void _showLogoutDialog(BuildContext context) {

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.ContainerColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffEAF7F1),
                  border: Border.all(
                    color: const Color(0xffD9F0E5),
                    width: 12,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.primary,
                  size: 35,
                ),
              ),

              const SizedBox(height: 13),

              /// TITLE
              Text(
                tr("logout"),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                tr("logout_confirmation"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),

              const SizedBox(height: 12),

              /// INFO BOX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xffE5F8EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr("logout_info"),
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 10,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      borderRadius: 15,
                      label: tr("cancel"),
                      onTap: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: AppButton(
                      borderRadius: 15,
                      label: tr("logout_action"),
                      icon: Icons.logout_rounded,
                      onTap: () async {
                       await ProfileLogic.logoutUser(context,dialogContext);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}