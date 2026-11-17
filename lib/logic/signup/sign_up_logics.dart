import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:smart_store/logic/signup/sign_up_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/app_messages.dart';
import '../../core/widgets/internet_check.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/CustomerSync.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../login/login_cubit.dart';

class SignUpLogics {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);
  static final service = AuthService();

  static String savedEmail = '';
  static Map<String, dynamic> formData = {};



  static Future<void> handleSignUp(Map<String, dynamic> data, BuildContext context,) async {

    InternetCheck.internetCheck(context);
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
    InternetCheck.internetCheck(context);
    try {
      ShowLoading.progressLoading(context);

      final response = await service.verifyOtp(
        email: savedEmail,
        token: pin,
      );

      if (response.user != null) {

        await service.createProfile(
          userId: response.user!.id,
          userName: (formData['user_name'] ?? '').toString(),
        );

        await repo.fetchAndSaveUser();
        await CustomerSyncService.syncCustomerWithLaravel(); // 🌟 استدعاء المزامنة

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

    bool hasNet = await InternetCheck.internetCheck(context);
    if (!hasNet) return;
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

  static Future<void> handleAvatarUpload(
      BuildContext context,
      Uint8List? imageBytes,
      VoidCallback? onSuccess,
      ) async {

    InternetCheck.internetCheck(context);

    if (imageBytes == null) {

      await completeRegistration(
        context,
        onSuccess,
      );

      return;
    }

    try {

      ShowLoading.progressLoading(context);

      final user = service.currentUser;

      if (user == null) return;

      await service.uploadAvatar(
        imageBytes,
        user.id,
      );

      if (context.mounted) {
        // التحميل مفتوح من فوق
        await completeRegistration(
          context,
          onSuccess,
          loadingShown: true,
        );
      }

    } catch (e) {

      if (context.mounted) {

        Navigator.of(
          context,
          rootNavigator: true,
        ).pop();

        AppToasts.showErrorToast(
          context,
          tr("upload_image_error"),
        );
      }
    }
  }
  static Future<void> completeRegistration(
      BuildContext context,
      VoidCallback? onSuccess, {
        bool loadingShown = false,
      }) async {

    // نعرض التحميل إذا ما كان معروض، حتى يكون عدد الإغلاقات ثابت
    if (!loadingShown) ShowLoading.progressLoading(context);

    try {
      await repo.fetchAndSaveUser();

      if (context.mounted) {
        context.read<LoginCubit>().setLoggedIn();
        Navigator.of(context, rootNavigator: true).pop(); // التحميل

        Navigator.pop(context); // صفحة إنشاء الحساب
        Navigator.pop(context); // نافذة تسجيل الدخول

        if (onSuccess != null) onSuccess();

        AppToasts.showSuccessToast(context, tr("login_success"),);
      }

    } catch (e) {
      // نغلق التحميل حتى لا يعلق المستخدم
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      debugPrint("Error completing registration: $e");
    }
  }
  // static Future<void> updateUserPhone(BuildContext context, String phoneNumber,) async {
  //
  //   // bool hasNet = await InternetCheck.internetCheck(context);
  //   // if (!hasNet) return;
  //   try {
  //     ShowLoading.progressLoading(context);
  //
  //     final user = service.currentUser;
  //     if (user == null) return;
  //
  //     await service.updatePhoneNumber(user.id, phoneNumber);
  //
  //     await repo.fetchAndSaveUser();
  //
  //     if (context.mounted) {
  //       context.read<LoginCubit>().setLoggedOut();
  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //       context.read<LoginCubit>().setLoggedIn();
  //     }
  //
  //     AppToasts.showSuccessToast(context,tr("phone_saved_success"),);
  //     // await Hive.box('user_info_box').put('phone', phoneNumber);
  //
  //   } catch (e) {
  //     Navigator.pop(context);
  //
  //     AppToasts.showErrorToast(context, tr("phone_save_failed"),
  //     );
  //   }
  // }


  // الرقم الذي أرسلنا له الرمز
  static String pendingPhone = '';

  // إرسال رمز التحقق للرقم، ترجع true عند النجاح
  static Future<bool> sendPhoneCode(BuildContext context, String phone) async {
    bool hasNet = await InternetCheck.internetCheck(context);
    if (!hasNet || !context.mounted) return false;

    ShowLoading.progressLoading(context);
    final res = await service.sendPhoneOtp(phone, context.locale.languageCode);
    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pop();

    if (res['success'] != true) {
      AppToasts.showErrorToast(context, tr(res['error'] ?? 'send_code_failed'));
      return false;
    }

    pendingPhone = phone;
    AppToasts.showSuccessToast(context, tr("phone_otp_sent"));
    return true;
  }

  // إعادة الإرسال من زر OtpStep
  static Future<void> handleResendPhoneCode(BuildContext context) async {
    if (pendingPhone.isEmpty) return;
    await sendPhoneCode(context, pendingPhone);
  }

  // التحقق من الرمز، يرمي خطأ إذا غلط حتى يمسح OtpStep الحقل
  static Future<void> verifyPhoneCode(BuildContext context, String pin) async {
    ShowLoading.progressLoading(context);
    final res = await service.verifyPhoneOtp(pendingPhone, pin);
    if (!context.mounted) return;

    if (res['success'] != true) {
      Navigator.of(context, rootNavigator: true).pop();
      AppToasts.showErrorToast(context, tr(res['error'] ?? 'invalid_otp'));
      throw Exception(res['error']);
    }

    // الرقم محفوظ من السيرفر، نحدث البيانات المحلية فقط
    try {
      await repo.fetchAndSaveUser();
      pendingPhone = '';

      if (context.mounted) {
        // نأخذها قبل إغلاق النافذة
        final loginCubit = context.read<LoginCubit>();
        final navigator = Navigator.of(context, rootNavigator: true);

        loginCubit.setLoggedOut();
        navigator.pop(); // التحميل
        navigator.pop(); // نافذة الرقم
        loginCubit.setLoggedIn();
        AppToasts.showSuccessToast(navigator.context, tr("phone_saved_success"));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        AppToasts.showErrorToast(context, tr("phone_save_failed"));
      }
    }
  }
}