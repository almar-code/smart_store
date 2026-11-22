import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/widgets/show_loading.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/icons/notification_icon.dart';
import '../../../core/widgets/icons/theme_icon.dart';
import '../../../core/widgets/internet_check.dart';
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

          bool hasPhone = UserLocal().hasPhone();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.background,
              titleSpacing: 5,
              title: UserProfile(),
              actions: [
                const NotificationIcon(),
                ThemeIcon(),
                InkWell(
                    onTap:() => showLogoutDialog(context),
                    child: AppIcon(icon: CupertinoIcons.person_crop_circle_badge_xmark)),
                SizedBox(width: 10),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.2 : 7,
                vertical: 20,
              ),
              child: Column(
                children: [
                  if(!hasPhone && state ) ...[
                    AddPhoneNumber(),
                  ],
                  Expanded(child: ProfileList()),
                ],
              ),
            ),
          );
        }
    );
  }

}

/// نافذة تأكيد تسجيل الخروج — عامة لإعادة استخدامها في صفحة إدارة الحساب
Future<void> showLogoutDialog(BuildContext context) async {
  bool isDesktop = MediaQuery.of(context).size.width > 800;

  bool connected = await NetworkService.hasInternet();
  if (!connected) {
    InternetCheck.internetCheck(context);
    return;
  }

  final red = AppColors.redColor;

  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: .45),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 420 : 340),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.ContainerColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.borderSecondary.withValues(alpha: .15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .18),
                  blurRadius: 40,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الجزء العلوي بخلفية متدرجة خفيفة
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, isDesktop ? 30 : 26, 20, isDesktop ? 22 : 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [red.withValues(alpha: .10), red.withValues(alpha: 0)],
                    ),
                  ),
                  child: Column(
                    children: [
                      // الأيقونة بحلقتين
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: red.withValues(alpha: .08),
                        ),
                        child: Container(
                          width: isDesktop ? 72 : 64,
                          height: isDesktop ? 72 : 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: red.withValues(alpha: .14),
                          ),
                          child: Icon(Icons.logout_rounded, color: red, size: isDesktop ? 32 : 28),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 18 : 14),
                      Text(
                        tr("logout"),
                        style: TextStyle(
                          fontSize: isDesktop ? 22 : 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr("logout_confirmation"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 14.5 : 13.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(isDesktop ? 22 : 18, 0, isDesktop ? 22 : 18, isDesktop ? 22 : 18),
                  child: Column(
                    children: [
                      // صندوق المعلومة
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tr("logout_info"),
                                style: TextStyle(
                                  height: 1.45,
                                  fontSize: isDesktop ? 12.5 : 11.5,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isDesktop ? 20 : 16),

                      // الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: isDesktop ? 50 : 46,
                              child: AppButton(
                                borderRadius: 15,
                                label: tr("cancel"),
                                color: AppColors.background,
                                textColor: AppColors.textColor,
                                borderColor: AppColors.borderSecondary.withValues(alpha: .4),
                                onTap: () => Navigator.pop(dialogContext),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: isDesktop ? 50 : 46,
                              child: AppButton(
                                borderRadius: 15,
                                label: tr("logout_action"),
                                icon: Icons.logout_rounded,
                                iconSize: 16,
                                color: red,
                                borderColor: red,
                                onTap: () async {
                                  await ProfileLogic.logoutUser(context, dialogContext);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        // حركة ظهور
            .animate()
            .fadeIn(duration: 220.ms)
            .scale(begin: const Offset(.92, .92), curve: Curves.easeOutBack, duration: 320.ms),
      );
    },
  );
}