import 'dart:io';

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

  Future<void> updateUserAvatar(File imageFile) async {

    final user = service.currentUser;
    if(user == null) return;

    await service.uploadAvatar(imageFile, user.id,);
  }
}