import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/internet_check.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../navigation/navigation_cubit.dart';
import '../notifications/notification_cubit.dart';
import 'login_cubit.dart';

class ProfileLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal());

  static Future<bool> updateAvatar(BuildContext context, {ImageSource source = ImageSource.gallery}) async {

    final picker = ImagePicker();

    try {

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile == null) return false;

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
      return true;

    } catch(e) {

      if (context.mounted) {

        Navigator.pop(context);

        AppToasts.showErrorToast(context, tr('avatar_update_failed'));
      }
      return false;
    }
  }

  // تنفيذ عملية مع فحص النت والتحميل والرسائل، ترجع true عند النجاح
  static Future<bool> _run(
      BuildContext context, {
        required Future<void> Function() action,
        required String successKey,
        required String errorKey,
      }) async {
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      if (context.mounted) InternetCheck.internetCheck(context);
      return false;
    }

    if (!context.mounted) return false;
    ShowLoading.progressLoading(context);

    try {
      await action();

      if (context.mounted) {
        // تحديث بيانات المستخدم في باقي الصفحات
        context.read<LoginCubit>().setLoggedOut();
        context.read<LoginCubit>().setLoggedIn();
        Navigator.pop(context);
        AppToasts.showSuccessToast(context, tr(successKey));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppToasts.showErrorToast(context, tr(errorKey));
      }
      return false;
    }
  }

  // تعديل الاسم
  static Future<bool> updateName(BuildContext context, String name) {
    return _run(
      context,
      action: () => repo.updateUserName(name.trim()),
      successKey: 'name_updated_success',
      errorKey: 'name_update_failed',
    );
  }


  // حذف الصورة الشخصية
  static Future<bool> deleteAvatar(BuildContext context) {
    return _run(
      context,
      action: () => repo.deleteUserAvatar(),
      successKey: 'avatar_deleted_success',
      errorKey: 'avatar_delete_failed',
    );
  }

  static Future<void> logoutUser(BuildContext context,BuildContext dialogContext) async {
    final navCubit = context.read<NavigationCubit>();
    try {
      ShowLoading.progressLoading(context);

      await repo.logout();
      context.read<NotificationCubit>().clear();

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