import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p_hn25/view_model/appointment_view_model.dart';
import 'package:p_hn25/view_model/auth_view_model.dart';
import 'package:p_hn25/view_model/family_view_model.dart';
import 'package:p_hn25/view_model/history_view_model.dart';
import 'package:p_hn25/view_model/notification_view_model.dart';
import 'package:p_hn25/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'view/screens/splash/splash_screen.dart';
import 'view_model/splash_view_model.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p_hn25/view_model/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:p_hn25/view_model/chat_view_model.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en'), Locale('miq')],
      path: 'assets/translations',
      fallbackLocale: const Locale('es'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => FamilyViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale.languageCode == 'miq'
                ? const Locale('es')
                : context.locale,

            title: 'MedicalHand',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme.copyWith(
              textTheme: GoogleFonts.sourceSans3TextTheme(
                ThemeData(
                  brightness: themeProvider.currentTheme.brightness,
                ).textTheme,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
