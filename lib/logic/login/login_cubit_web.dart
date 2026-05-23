import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/user_local.dart';
import '../../data/repos/auth_repo.dart';
import '../../data/services/auth_service.dart';

class LoginCubitWeb extends Cubit<bool> {

  LoginCubitWeb() : super(false) {
    init();
  }

  final supabase = Supabase.instance.client;

  bool _hasFetchedUser = false; // 👈 أهم سطر

  void init() {

    checkAuthStatus();

    supabase.auth.onAuthStateChange.listen((data) {

      final session = data.session;

      emit(session != null);

      // 👇 هذا الشرط يمنع التكرار
      if (session != null && !_hasFetchedUser) {

        _hasFetchedUser = true;

        _fetchUserOnce();
      }

      // لو logout رجع flag
      if (session == null) {
        _hasFetchedUser = false;
      }
    });
  }

  Future<void> checkAuthStatus() async {

    await Future.delayed(const Duration(milliseconds: 500),);
    final session = supabase.auth.currentSession;
    emit(session != null);

    if (session != null && !_hasFetchedUser) {
      _hasFetchedUser = true;_fetchUserOnce();
    }
  }

  Future<void> _fetchUserOnce() async {

    final repo = AuthRepo(service: AuthService(), local: UserLocal(),);

    await repo.fetchAndSaveUser();
  }
}