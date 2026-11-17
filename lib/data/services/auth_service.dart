import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/widgets/image_helper.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final String serverClientId = dotenv.env['serverClientId'] ?? '';
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(
      {required String email, required String password,}) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }


  Future<AuthResponse> verifyOtp(
      {required String email, required String token,}) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  // الرقم يضاف لاحقا من الحساب بعد التحقق
  Future<void> createProfile(
      {required String userId, required String userName,}) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'user_name': userName,
    });
  }

  Future<void> resendCode(String email) async {
    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<Map<String, dynamic>?> fetchUser() async {
    final user = _supabase.auth.currentUser;

    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select('user_name,avatar_url,phone_number')
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      String? base64Image;

      if (data['avatar_url'] != null && data['avatar_url']
          .toString()
          .isNotEmpty) {
        try {
          base64Image =
          await ImageHelper.convertUrlToBase64(data['avatar_url']);
        } catch (e) {
          print("⚠️ فشل تحويل الصورة إلى Base64: ");
        }
      }

      return {
        'user_id': user.id,
        'name': data['user_name'],
        'email': user.email,
        'phone': data['phone_number'],
        'image': base64Image,
      };
    }
    return null;
  }


  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse?> signInWithGoogle() async {
    // ===== Web =====
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:5050',
        // تأكد أن هذا البورت هو نفسه اللي شغال عليه المشروع
        authScreenLaunchMode: LaunchMode.platformDefault,
        // هذا السطر هو السر في إظهار قائمة الحسابات في كل مرة في الويب
        queryParams: {
          'prompt': 'select_account',
        },
      );
      return null;
    }

    // ===== Android =====
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: serverClientId,
    );

    // تسجيل الخروج يضمن ظهور قائمة الحسابات في الأندرويد
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw 'تم الغاء عمليه تسجيل الدخول';
    }

    final GoogleSignInAuthentication googleAuth = await googleUser
        .authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }


  Future<void> sendResetCode(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyRecoveryOtp(
      {required String email, required String token}) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }


  // Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
  //   await _supabase
  //       .from('profiles')
  //       .update({'phone_number': phoneNumber})
  //       .eq('id', userId);
  // }

  // إرسال رمز التحقق للرقم عبر دالة Supabase
  Future<Map<String, dynamic>> sendPhoneOtp(String phone, String lang) {
    return _invokeFunction('send-phone-otp', {'phone': phone, 'lang': lang});
  }

  // التحقق من الرمز، والدالة تحفظ الرقم عند النجاح فقط
  Future<Map<String, dynamic>> verifyPhoneOtp(String phone, String code) {
    return _invokeFunction('verify-phone-otp', {'phone': phone, 'code': code});
  }

  Future<Map<String, dynamic>> _invokeFunction(String name, Map<String, dynamic> body) async {
    try {
      final res = await _supabase.functions.invoke(name, body: body);
      return Map<String, dynamic>.from(res.data as Map);
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map) return Map<String, dynamic>.from(details);
      return {'success': false, 'error': 'unexpected_error'};
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }


  Future<String> uploadAvatar(Uint8List imageBytes,
      String userId,) async {
    // الرابط القديم قبل الرفع
    final oldUrl = await _currentAvatarUrl(userId);

    final fileName =
        'avatar_${userId}_${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from('avatars')
        .uploadBinary(
      fileName,
      imageBytes,
    );

    final url = _supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

    await _supabase
        .from('profiles')
        .update({
      'avatar_url': url,
    })
        .eq('id', userId);

    // حذف الصورة القديمة بعد حفظ الجديدة
    if (oldUrl != url) await _deleteAvatarFile(oldUrl);

    return url;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser =>
      _supabase.auth.currentUser;

  Future<void> signInWithFacebook() async {
    // فيسبوك عبر المتصفح في الويب والجوال
    // فيسبوك عبر متصفح داخل التطبيق
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: kIsWeb
          ? 'http://localhost:5050'
          : 'io.supabase.smartstore://login-callback/',
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.inAppBrowserView,
      scopes: 'email,public_profile',
    );
  }

  // انتظار رجوع المستخدم مسجلا من المتصفح
  Future<Session?> waitForSession({Duration timeout = const Duration(minutes: 2)}) async {
    try {
      final state = await _supabase.auth.onAuthStateChange
          .firstWhere((s) => s.event == AuthChangeEvent.signedIn && s.session != null)
          .timeout(timeout);
      return state.session;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserName(String userId, String userName) async {
    await _supabase
        .from('profiles')
        .update({'user_name': userName})
        .eq('id', userId);
  }
  // حذف الصورة من التخزين وتفريغ الرابط
  Future<void> removeAvatar(String userId) async {
    final url = await _currentAvatarUrl(userId);

    await _deleteAvatarFile(url);

    await _supabase
        .from('profiles')
        .update({'avatar_url': null})
        .eq('id', userId);
  }

  // رابط الصورة الحالي من الملف الشخصي
  Future<String?> _currentAvatarUrl(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    return data?['avatar_url']?.toString();
  }

  // مسار الملف داخل باكت الصور، فاضي إذا الرابط خارجي مثل صورة جوجل
  String? _avatarPath(String? url) {
    if (url == null || url.isEmpty) return null;
    const marker = '/storage/v1/object/public/avatars/';
    final index = url.indexOf(marker);
    if (index == -1) return null;
    return Uri.decodeComponent(url.substring(index + marker.length).split('?').first);
  }

  // حذف ملف الصورة من الباكت، ترجع true إذا انحذف فعلا
  Future<bool> _deleteAvatarFile(String? url) async {
    final path = _avatarPath(url);
    if (path == null) return false;

    try {
      final removed = await _supabase.storage.from('avatars').remove([path]);
      // قائمة فاضية تعني أن سياسات التخزين منعت الحذف
      if (removed.isEmpty) debugPrint('Avatar not deleted, check storage policies: $path');
      return removed.isNotEmpty;
    } catch (e) {
      // فشل حذف الملف لا يمنع باقي العملية
      debugPrint('Avatar delete error: $e');
      return false;
    }
  }

}