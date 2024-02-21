import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double strokeWidth;
  final Color? color;

  const Loader({
    super.key,
    this.strokeWidth = 4.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color ?? ColorUtils.primary, strokeWidth: strokeWidth),
    );
  }
}
