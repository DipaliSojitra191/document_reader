import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  AppTheme._();

  static const font = "Montserrat";

  static ThemeData lightTheme() => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: ColorUtils.white,
        // pageTransitionsTheme: const PageTransitionsTheme(
        //   builders: {
        //     TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        //   },
        // ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorUtils.primary,
          selectionColor: ColorUtils.primary,
          selectionHandleColor: ColorUtils.primary,
        ),
        primaryColor: ColorUtils.primary,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        fontFamily: font,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: ColorUtils.white,
          iconTheme: IconThemeData(color: ColorUtils.black),
          titleTextStyle: TextStyle(fontSize: 18.sp, color: ColorUtils.black),
        ),
        textTheme: TextTheme(
          displaySmall: TextStyle(
            color: ColorUtils.black,
            fontSize: 14.sp,
            fontFamily: "MontserratMedium",
            fontWeight: FontWeight.w400,
          ),
          displayMedium: TextStyle(
            fontSize: 17.sp,
            color: ColorUtils.black,
            fontWeight: FontWeight.bold,
            fontFamily: font,
          ),

          ///
          bodySmall: TextStyle(
            color: ColorUtils.black,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontFamily: font,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.sp,
            fontFamily: font,
            color: ColorUtils.black,
            fontWeight: FontWeight.w400,
          ),
          bodyLarge: TextStyle(
            color: ColorUtils.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            fontFamily: font,
          ),
        ),
      );
}
