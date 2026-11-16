import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../local/user_local.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepo {

  final AuthService service;
  final UserLocal local;

  AuthRepo({
    required this.service,
    required this.local,
  });

  Future<void> fetchAndSaveUser() async {

    final data = await service.fetchUser();

    if(data == null) return;

    final user = UserModel.fromMap(data);

    await local.saveUser(user);
  }

  Future<UserModel?> getLocalUser() async {

    return await local.getUser();
  }

  Future<void> logout() async {

    await service.signOut();
    await local.clearUser();
  }

  Future<void> updateUserAvatar(
      Uint8List imageBytes,
      ) async {

    final user = service.currentUser;

    if(user == null) return;

    await service.uploadAvatar(
      imageBytes,
      user.id,
    );
  }
  // تعديل الاسم في Supabase ثم محلياً
  Future<void> updateUserName(String name) async {
    final user = service.currentUser;
    if (user == null) return;
    await service.updateUserName(user.id, name);
    await local.updateName(name);
  }

  // حذف الصورة من Supabase ثم محلياً
  Future<void> deleteUserAvatar() async {
    final user = service.currentUser;
    if (user == null) return;
    await service.removeAvatar(user.id);
    await local.updateImage('');
  }
}