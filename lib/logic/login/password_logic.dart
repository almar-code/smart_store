import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/app_messages.dart';
import '../../core/widgets/network_service.dart';
import '../../core/widgets/show_loading.dart';
import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';
import '../signup/sign_up_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PasswordLogic {

  static final repo = AuthRepo(service: AuthService(), local: UserLocal(),);

  static final service = AuthService();


  static  String savedEmail="";
  static  Map<String, dynamic> formData = {};



  static void maserror(BuildContext context ) async{
    bool connected = await NetworkService.hasInternet();
    if (!connected) {
      AppToasts.showErrorToast(context,"لا يوجد اتصال بالإنترنت، يرجى المحاولة لاحقاً");
      return;}
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
      AppToasts.showSuccessToast(context,"تم إرسال رمز التحقق إلى بريدك الإلكتروني");


    } catch (e) {
      Navigator.pop(context);
      AppToasts.showErrorToast(context,"خطأ في إرسال الرمز ");
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
        AppToasts.showErrorToast(context,"الرمز غير صحيح أو انتهت صلاحيته");

      }
    }
  }

  static Future<void> updateNewPassword(BuildContext context, Map<String, dynamic> data) async {
    maserror(context);
    try {
      ShowLoading.progressLoading(context);
      await service.updatePassword( data['password']!.toString().trim());

      if (context.mounted) {
        Navigator.pop(context);
        AppToasts.showSuccessToast(context, "تم تغيير كلمة المرور بنجاح");
        Navigator.pop(context);
      }

    } on AuthException catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (e.message.contains("same as the old one") || e.message.contains("previously used")) {
        AppToasts.showErrorToast(context, "عفواً! لا يمكنك استخدام كلمة مرور قديمة، اختر كلمة جديدة");
      } else if (e.message.contains("at least 9 characters")) {
        AppToasts.showErrorToast(context, "كلمة المرور ضعيفة جداً، يجب أن تكون 6 خانات على الأقل");
      } else {
        AppToasts.showErrorToast(context, "فشل التحديث: ${e.message}");
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      AppToasts.showErrorToast(context, "حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى لاحقاً");
      debugPrint("Unexpected Password Update Error: $e");
    }
  }

}