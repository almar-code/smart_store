import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../constants/app_colors.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(false)) {
    on<ToggleThemeEvent>(_toggleTheme);
    _loadTheme();
  }

  void _toggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDark;

    await prefs.setBool("isDark", newValue);

    // ربط الألوان
    AppColors.isDark.value = newValue;

    emit(ThemeState(newValue));
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("isDark") ?? false;

    // تحميل الحالة
    AppColors.isDark.value = isDark;

    emit(ThemeState(isDark));
  }
}