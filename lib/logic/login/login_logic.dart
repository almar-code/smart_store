import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import 'login_cubit.dart';

class LoginLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);
  static final service = AuthService();

  static void maserror(BuildContext context) async {
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      AppToasts.showErrorToast(
        context,
        tr("no_internet"),
      );
      return;
    }
  }

  static Future<void> signIn(BuildContext context, String email, String password, VoidCallback? onSuccess) async {

    maserror(context);

    try {
      ShowLoading.progressLoading(context);

      final AuthResponse res =
      await service.signInWithPassword(email, password);

      if (res.session != null) {
        await repo.fetchAndSaveUser();

        if (context.mounted) {
          context.read<LoginCubit>().setLoggedIn();

          Navigator.pop(context);
          Navigator.pop(context);

          if (onSuccess != null) {
            onSuccess();
          }
        }

        AppToasts.showSuccessToast(context, tr("login_success"),);
      }

    } catch (e) {
      Navigator.pop(context);

      AppToasts.showErrorToast(context, tr("login_failed"),);
    }
  }

  static Future<void> googleSignIn(BuildContext context, VoidCallback? onSuccess,) async {

    maserror(context);

    try {
      ShowLoading.progressLoading(context);

      final AuthResponse res =
      await service.signInWithGoogle();

      if (res.session != null) {
        await repo.fetchAndSaveUser();

        if (context.mounted) {
          context.read<LoginCubit>().setLoggedIn();

          Navigator.pop(context);
          Navigator.pop(context);

          if (onSuccess != null) {
            onSuccess();
          }

          AppToasts.showSuccessToast(context, tr("login_success"),);
        }
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        AppToasts.showErrorToast(context,tr("google_login_failed"),);
      }
    }
  }
}