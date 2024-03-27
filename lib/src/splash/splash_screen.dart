// ignore_for_file: file_names

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
  @override
  void initState() {
    super.initState();
    checkInternetConnection(context: context);
    Future.delayed(const Duration(seconds: 3), () {
      removeRoute(const BottomBarScreen(), context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('splash'),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.asset(ImageString.splash, fit: BoxFit.fill),
      ),
    );
  }
}
