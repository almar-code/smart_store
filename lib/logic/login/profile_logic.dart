import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../navigation/navigation_cubit.dart';
import 'login_cubit.dart';

class ProfileLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal());

  static Future<void> updateAvatar(BuildContext context,) async {

    final picker = ImagePicker();

    try {

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile == null) return;

      ShowLoading.progressLoading(context);

      Uint8List imageBytes =
      await pickedFile.readAsBytes();

      await repo.updateUserAvatar(imageBytes);

      await repo.fetchAndSaveUser();

      if (context.mounted) {
        context.read<LoginCubit>().setLoggedOut();
        context.read<LoginCubit>().setLoggedIn();
        Navigator.pop(context);

        AppToasts.showSuccessToast(context, tr('avatar_updated_success'));
      }

    } catch(e) {

      if (context.mounted) {

        Navigator.pop(context);

        AppToasts.showErrorToast(context, tr('avatar_update_failed'));
      }
    }
  }

  static Future<void> logoutUser(BuildContext context,BuildContext dialogContext) async {
    final navCubit = context.read<NavigationCubit>();
    try {
      ShowLoading.progressLoading(context);

      await repo.logout();

      context.read<LoginCubit>().setLoggedOut();

      if (context.mounted) {
        navCubit.updateIndex(2);

        Navigator.pop(context);
        Navigator.pop(dialogContext);

        AppToasts.showSuccessToast(
          context,
          tr("logout_success"),
        );
      }
    } catch (e) {
      AppToasts.showErrorToast(
        context,
        tr("internet_connection_error"),
      );
    }
  }
}