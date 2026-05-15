import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/logic/signup/sign_up_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../login/login_cubit.dart';

class SignUpLogics {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);
  static final service = AuthService();

  static String savedEmail = '';
  static Map<String, dynamic> formData = {};

  static void networkService(BuildContext context) async {
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      AppToasts.showErrorToast(context, tr("no_internet"));
      return;
    }
  }

  static Future<void> handleSignUp(Map<String, dynamic> data, BuildContext context,) async {

    networkService(context);
    formData = data;
    savedEmail = formData['email']!.toString().trim();

    try {
      ShowLoading.progressLoading(context);

      final response = await service.signUp(
        email: savedEmail,
        password: formData['password'],
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (response.user?.identities?.isNotEmpty ?? false) {
        context.read<SignUpCubit>().next();

        AppToasts.showSuccessToast(context, tr("otp_sent_success"),);

      } else {
        AppToasts.showErrorToast(
          context,
          tr("account_exists"),
        );
      }

    } on AuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      AppToasts.showErrorToast(context, e.message);
    }
  }


  static Future<void> handleVerifyAndSave(String pin, BuildContext context,) async {
    networkService(context);
    try {
      ShowLoading.progressLoading(context);

      final response = await service.verifyOtp(
        email: savedEmail,
        token: pin,
      );

      if (response.user != null) {

        await service.createProfile(
          userId: response.user!.id,
          userName: formData['user_name'],
          phone: formData['phone_number'],
        );

        await repo.fetchAndSaveUser();

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.read<SignUpCubit>().next();

          AppToasts.showSuccessToast(context, tr("otp_verify_success"),);
        }
      }

    } on AuthException catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        AppToasts.showErrorToast(context, tr("otp_verify_failed"),);
      }
      rethrow;

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        AppToasts.showErrorToast(context, tr("unexpected_error"),);
      }
      rethrow;
    }
  }

  static Future<void> handleResendCode(BuildContext context) async {

    networkService(context);

    if (savedEmail.isEmpty) return;

    try {
      ShowLoading.progressLoading(context);

      await service.resendCode(savedEmail);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        AppToasts.showSuccessToast(context, tr("otp_resend_success"),);
      }

    } on AuthException catch (error) {
      if (context.mounted) Navigator.pop(context);

      AppToasts.showErrorToast(context, tr("otp_resend_error"),);
    }
  }

  static Future<void> handleAvatarUpload(BuildContext context, File? imageFile, VoidCallback? onSuccess) async {

    networkService(context);

    if (imageFile == null) {
      await completeRegistration(context, onSuccess);
      return;
    }

    try {
      ShowLoading.progressLoading(context);

      final user = service.currentUser;
      if (user == null) return;

      await service.uploadAvatar(imageFile, user.id);

      if (context.mounted) {
        await completeRegistration(context, onSuccess);
      }

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        AppToasts.showErrorToast(context, tr("upload_image_error"),);
      }
    }
  }

  static Future<void> completeRegistration(BuildContext context, VoidCallback? onSuccess,) async {

    try {
      await repo.fetchAndSaveUser();

      if (context.mounted) {
        context.read<LoginCubit>().setLoggedIn();
        Navigator.of(context, rootNavigator: true).pop();

        Navigator.pop(context);
        Navigator.pop(context);

        if (onSuccess != null) onSuccess();

        AppToasts.showSuccessToast(context, tr("login_success"),);
      }

    } catch (e) {
      debugPrint("Error completing registration: $e");
    }
  }

  static Future<void> updateUserPhone(BuildContext context, String phoneNumber,) async {

    networkService(context);

    try {
      ShowLoading.progressLoading(context);

      final user = service.currentUser;
      if (user == null) return;

      await service.updatePhoneNumber(user.id, phoneNumber);

      await repo.fetchAndSaveUser();

      if (context.mounted) {
        context.read<LoginCubit>().setLoggedOut();
        Navigator.pop(context);
        Navigator.pop(context);
        context.read<LoginCubit>().setLoggedIn();
      }

      AppToasts.showSuccessToast(context,tr("phone_saved_success"),);
      await Hive.box('user_info_box').put('phone', phoneNumber);

    } catch (e) {
      Navigator.pop(context);

      AppToasts.showErrorToast(context, tr("phone_save_failed"),
      );
    }
  }
}