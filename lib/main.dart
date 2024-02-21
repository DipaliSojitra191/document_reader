import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/onboarding/onboarding.dart';
import 'package:document_reader/src/splash/splash_Screen.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await PrefsRepo.init();
  // runApp(const Test());
  runApp(const MyApp());
}

StreamController<Locale> languageStream = StreamController();
StreamSubscription<ConnectivityResult>? connectivitySubscription;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return const ClampingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PrefsRepo prefsRepo = PrefsRepo();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      checkInternetConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Locale>(
      initialData: const Locale('en', 'US'),
      stream: languageStream.stream,
      builder: (context, languageSnapshot) {
        Locale language = getLocaleFromName(
          languageName: prefsRepo.getString(key: PrefsRepo.language),
        );
        if (language != languageSnapshot.data) {
          languageStream.add(language);
        }

        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              scrollBehavior: const ScrollBehaviorModified(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: languageSnapshot.data,
              supportedLocales: const [
                Locale('en', "US"),
                Locale('ar', 'AR'),
                Locale('bg', 'BG'),
                Locale('cs', 'CZ'),
                Locale('fr', 'CR'),
                Locale('pl', 'PL'),
              ],
              theme: AppTheme.lightTheme(),
              debugShowCheckedModeBanner: false,
              home: child,
            );
          },
          child: prefsRepo.getBool(key: PrefsRepo.onboarding) ? const SplashScreen() : const OnBoarding(),
        );
      },
    );
  }
}
