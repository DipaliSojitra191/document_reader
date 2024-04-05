import 'dart:async';

import 'package:document_reader/shared_Preference/preferences_helper.dart';
import 'package:document_reader/src/bottombar/bottombar.dart';
import 'package:document_reader/utils/AppImages.dart';
import 'package:document_reader/utils/common_functions.dart';
import 'package:document_reader/utils/navigation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PrefsRepo prefsRepo = PrefsRepo();
  Timer? timer;

  @override
  void initState() {
    checkInternetConnection(context: context);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.tick > 2) {
        if (context.mounted) {
          timer.cancel();
          removeRoute(navigate: const BottomBarScreen(), context: context);
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      key: const Key('splash'),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset(ImageString.splash, fit: BoxFit.fill),
      ),
    );
  }
}
