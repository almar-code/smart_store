import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/widgets/image_helper.dart';

class AuthService {

  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({required String email, required String password,}) async {

    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }


  Future<AuthResponse> verifyOtp({required String email, required String token,}) async {

    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<void> createProfile({required String userId, required String userName, required String phone,}) async {

    await _supabase.from('profiles').upsert({
      'id': userId,
      'user_name': userName,
      'phone_number': phone,
    });
  }

  Future<void> resendCode(String email) async {

    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<Map<String,dynamic>?> fetchUser() async {

    final user = _supabase.auth.currentUser;

    if(user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select('user_name,avatar_url,phone_number')
        .eq('id', user.id)
        .maybeSingle();

    if(data != null) {

    String? base64Image;

    if (data['avatar_url'] != null && data['avatar_url'].toString().isNotEmpty) {
      try {
        base64Image = await ImageHelper.convertUrlToBase64(data['avatar_url']);
      } catch (e) {
        print("⚠️ فشل تحويل الصورة إلى Base64: $e");

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

  Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '820798311765-t188u7hleou6qtb16ttvcrnmio8bt4hh.apps.googleusercontent.com',
    );

    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw 'تم الغاء عمليه تسجيل الدخول ';

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw 'No ID Token found.';

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }









  Future<void> sendResetCode(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyRecoveryOtp({required String email, required String token}) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }



  Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
    await _supabase
        .from('profiles')
        .update({'phone_number': phoneNumber})
        .eq('id', userId);
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }






  Future<String> uploadAvatar(
      File imageFile,
      String userId,
      ) async {

    final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage
        .from('avatars')
        .upload(fileName, imageFile);

    final url = _supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

    await _supabase.from('profiles').update({'avatar_url': url,
    })
        .eq('id', userId);

    return url;
  }



  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser =>
      _supabase.auth.currentUser;
}