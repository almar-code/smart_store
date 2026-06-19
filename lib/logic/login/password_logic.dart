import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart'; // إضافة مكتبة الترجمة
import '../../core/widgets/app_messages.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../signup/sign_up_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_cubit.dart';

class PasswordLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);

  static final service = AuthService();


  static  String savedEmail="";
  static  Map<String, dynamic> formData = {};



  static void maserror(BuildContext context ) async{
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      AppToasts.showErrorToast(context, tr("errors.no_internet"));
      return;
    }
  }

  static Future<void> sendResetPasswordCode(BuildContext context, Map<String, dynamic> data) async {
    maserror(context);
    formData = data;
    savedEmail = formData['email']!.toString().trim();
    try {
      ShowLoading.progressLoading(context);

      await service.sendResetCode(savedEmail);

      Navigator.pop(context);

      context.read<SignUpCubit>().next();
      AppToasts.showSuccessToast(context, tr("success.code_sent"));


    } catch (e) {
      Navigator.pop(context);
      AppToasts.showErrorToast(context, tr("errors.send_code_failed"));
    }
  }

  static Future<void> verifyOtpCode(BuildContext context, String token) async {
    try {
      ShowLoading.progressLoading(context);

      await service.verifyRecoveryOtp(
        email: savedEmail,
        token: token,
      );

      if (context.mounted) {
        Navigator.pop(context);
        context.read<SignUpCubit>().next();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppToasts.showErrorToast(context, tr("errors.invalid_otp"));

      }
    }
  }

  static Future<void> updateNewPassword(BuildContext context, Map<String, dynamic> data, VoidCallback? onSuccess) async {
    maserror(context);
    try {
      ShowLoading.progressLoading(context);
      await service.updatePassword(data['password']!.toString().trim());

      await repo.fetchAndSaveUser();

      if (context.mounted) {
        Navigator.pop(context);

        context.read<LoginCubit>().setLoggedIn();

        Navigator.pop(context);
      }
      if (onSuccess != null) onSuccess();
      AppToasts.showSuccessToast(context, tr("success.password_updated"));

    } on AuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (e.message.contains("same as the old one") || e.message.contains("previously used")) {
        AppToasts.showErrorToast(context, tr("errors.old_password"));
      } else if (e.message.contains("at least 9 characters")) {
        AppToasts.showErrorToast(context, tr("errors.weak_password"));
      } else {
        AppToasts.showErrorToast(context, "${tr("errors.update_failed")}${e.message}");
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      AppToasts.showErrorToast(context, tr("errors.unexpected"));
      debugPrint("Unexpected Password Update Error: $e");
    }
  }

}