import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/internet_check.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import 'login_cubit.dart';

class LoginLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);
  static final service = AuthService();

  static Future<void> signIn(BuildContext context, String email, String password, VoidCallback? onSuccess) async {

    InternetCheck.internetCheck(context);

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

  static Future<void> googleSignIn(BuildContext context, VoidCallback? onSuccess) async {

    bool hasNet = await InternetCheck.internetCheck(context);
    if (!hasNet) return;

    try {
      ShowLoading.progressLoading(context);

      final res = await service.signInWithGoogle();

      if (kIsWeb) {
        if (context.mounted) Navigator.pop(context);
        return;
      }

      if (res != null && res.session != null) {
        try {
          await repo.fetchAndSaveUser();
        } catch (e) {
          await Supabase.instance.client.auth.signOut();
          throw Exception("Failed to fetch user data due to weak internet");
        }

        if (context.mounted) {
          context.read<LoginCubit>().setLoggedIn();
          Navigator.pop(context);
          Navigator.pop(context);

          if (onSuccess != null) {
            onSuccess();
          }

          AppToasts.showSuccessToast(context, tr("login_success"));
        }
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppToasts.showErrorToast(context, tr("google_login_failed"));
      }
    }
  }
}