import 'package:document_reader/utils/AppColors.dart';
import 'package:document_reader/utils/circular_progrss_indicator.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final double? radius;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? bgColor;
  final Color? textColor;
  final Color? c1;
  final BoxBorder? border;
  final bool? loader;

  final List<BoxShadow>? shadow;

  const CustomBtn({
    super.key,
    required this.title,
    this.onTap,
    this.radius,
    this.height,
    this.width,
    this.fontSize,
    this.bgColor,
    this.textColor,
    this.shadow,
    this.border,
    this.c1,
    this.loader,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: ColorUtils.transparent,
      splashColor: ColorUtils.transparent,
      highlightColor: ColorUtils.transparent,
      borderRadius: BorderRadius.circular(radius ?? 10),
      child: Container(
        height: height ?? 45.h,
        width: width ?? 180.w,
        decoration: BoxDecoration(
          border: border,
          boxShadow: shadow ?? [],
          gradient: commonGradient(c1: c1),
          borderRadius: BorderRadius.circular(radius ?? 20.w),
        ),
        child: Center(
          child: (loader ?? false)
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const Loader(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ColorUtils.white),
                ),
        ),
      ),
    );
  }
}
