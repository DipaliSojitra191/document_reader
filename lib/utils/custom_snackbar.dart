import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

showSnackBar({
  bool? errorSnackBar,
  required BuildContext context,
  required String message,
}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ColorUtils.white, fontSize: 15.sp),
    ),
    duration: const Duration(seconds: 3),
    padding: EdgeInsets.all(25.w),
    backgroundColor: errorSnackBar == true ? ColorUtils.red : ColorUtils.green66,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
