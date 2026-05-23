import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/core/widgets/show_loading.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_event.dart';
import '../../../core/widgets/app_messages.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/network_service.dart';
import '../../../core/widgets/user_profile.dart';
import '../../../data/local/user_local.dart';
import '../../../data/repos/auth_repo.dart';
import '../../../data/services/auth_service.dart';
import '../../../logic/login/login_cubit.dart';
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
                AppIcon(icon:  AppColors.isDark.value ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,onPressed: (){
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },),
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
  final navCubit = context.read<NavigationCubit>();
  final repo = AuthRepo(
    service: AuthService(),
    local: UserLocal(),
  );
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("تسجيل الخروج"),
      content: const Text("هل أنت متأكد؟"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () async {
            // bool isConnected = await NetworkService.hasInternet();
            // if (!isConnected) {
            //   AppToasts.showErrorToast(context,"عذراً، لا يوجد اتصال بالإنترنت");
            //   return;
            // }
            try {
              ShowLoading.progressLoading(context);
              await repo.logout();
              context.read<LoginCubit>().setLoggedOut();
              if (context.mounted) {
                navCubit.updateIndex(2);
                Navigator.pop(context);
                Navigator.pop(dialogContext);
                AppToasts.showSuccessToast(context,"تم تسجيل الخروج بنجاح ");

              }

            } catch (e) {
              AppToasts.showErrorToast(context,"هناك خطى تاكد من اتصالك بالانترنت ");

            }
          },
          child: const Text("خروج", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
