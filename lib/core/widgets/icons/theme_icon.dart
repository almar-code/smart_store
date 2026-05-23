import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/bloc/theme_bloc.dart';
import '../../theme/bloc/theme_event.dart';
import '../../theme/bloc/theme_state.dart';
import 'app_icon.dart';

class ThemeIcon extends StatelessWidget {
  const ThemeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        // فحص حالة الثيم الحالية من البلوك (قم بتعديل الشرط حسب مسميات الـ State عندك مثلاً state is DarkThemeState)
        final bool isDark = context.read<ThemeBloc>().state.isDark;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 2000),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: animation,
                child: child,
              ),
            );
          },
          // نقل الـ ValueKey إلى المستوى الخارجي ليفهمه الـ AnimatedSwitcher حتماً
          child: isDark
              ? SizedBox(
            key: const ValueKey('sun_mode_key'), // المفتاح الخارجي للطرف الأول
            child: AppIcon(
              icon: Icons.wb_sunny_outlined,
              color: Colors.deepOrangeAccent,
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            ),
          )
              : SizedBox(
            key: const ValueKey('dark_mode_key'), // المفتاح الخارجي للطرف الثاني
            child: AppIcon(
              icon: Icons.dark_mode_outlined,
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            ),
          ),
        );
      },
    );
  }
}
