import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local/user_local.dart';
import 'data/repos/auth_repo.dart';
import 'data/services/auth_service.dart';
import 'logic/login/login_cubit.dart';
import 'logic/login/login_cubit_web.dart';
import 'logic/signup/sign_up_cubit.dart';
import 'logic/navigation/navigation_cubit.dart';
import 'my_app.dart';
import 'core/theme/bloc/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('user_info_box');
  final String supaBaseKey = dotenv.env['supaBase_AnonKey'] ?? '';
  await Supabase.initialize(
    url: 'https://vwhumdnzaljjpuwvtdbo.supabase.co',
    anonKey: supaBaseKey, // المفتاح من صورتك الأخيرة
  );

  // await dotenv.load(fileName: ".env");
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('en'),
      saveLocale: true,
      child:  MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(create: (_) => SignUpCubit()),
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(create: (_) => LoginCubit()),
          BlocProvider(create: (_) => LoginCubitWeb())
        ],


          child: BlocBuilder<LoginCubitWeb, bool>(
              builder: (context, state) {
              return MyApp();
            }
          ),
        ),
      ),
  );
}