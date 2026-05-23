import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<bool> {

  LoginCubit() : super(false) {
    checkAuthStatus();
  }

  final supabase = Supabase.instance.client;

  void checkAuthStatus() {

    final session = supabase.auth.currentSession;

    emit(session != null);
  }

  void setLoggedIn() {
    emit(true);
  }

  void setLoggedOut() {
    emit(false);
  }
}