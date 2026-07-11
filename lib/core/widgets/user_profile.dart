import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../../logic/login/login_cubit.dart';
import '../../logic/login/profile_logic.dart';
import '../../views/widgets/flash/flash_screen.dart';
import '../constants/app_colors.dart';
import 'app_title.dart';
import 'circleImage/circle_image.dart';
import 'image_helper.dart';


class UserProfile extends StatelessWidget {
  final bool isDrawer;
   UserProfile({super.key, this.isDrawer = false});

  final repo = AuthRepo(
    service: AuthService(),
    local: UserLocal(),
  );
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocBuilder<LoginCubit, bool>(
      builder: (context, state) {
        return  (state)
            ? FutureBuilder(
          future: repo.getLocalUser(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting || !asyncSnapshot.hasData) {
              return const UserProfileShimmer();
            }
            var userData = asyncSnapshot.data!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: isDrawer ? () {} : () {
                    _showLargeImage(context, userData.image);
                  },
                  child: CircleAvatar(
                    radius: isDesktop ? 23 : 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (userData.image.toString().isNotEmpty)
                        ? MemoryImage(ImageHelper.decodeBase64(userData.image))
                        : null,
                    child: (userData.image == '' || userData.image.toString().isEmpty)
                        ? Icon(Icons.person, size: isDesktop ? 23 : 20, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userData.name ,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: isDesktop ? 17 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData.email,
                      style: TextStyle(
                          fontSize: isDesktop ? 15 : 12,
                          color: AppColors.textSecondary),
                    )
                  ],
                ),
              ],
            );
          },
        ) : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
        const CircleImage(
        imagePath: '',
        radius: 20,
        icon: CupertinoIcons.person,
        ),
        const SizedBox(width: 7),
        AppTitle(firstPart: 'Log', secondPart: 'in'),
        ],
        );
      },
    );
  }

  void _showLargeImage(BuildContext context, String? image) {
    showDialog(
      context: context,
      builder: (dialogContext) => Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 150,
                backgroundColor: AppColors.background,
                backgroundImage: (image != null && image.isNotEmpty)
                    ? MemoryImage(ImageHelper.decodeBase64(image))
                    : null,
                child: (image == null || image.isEmpty)
                    ?  Icon(Icons.person, size: 100, color: AppColors.iconColor)
                    : null,
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await ProfileLogic.updateAvatar(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderColor, width: 2),
                    ),
                    child: Icon(
                      CupertinoIcons.pencil,
                      color: AppColors.iconColor,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}