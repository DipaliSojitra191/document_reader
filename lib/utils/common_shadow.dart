import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';

List<BoxShadow>? commonShadow({Color? color}) => [
      BoxShadow(
        offset: const Offset(0, 3),
        blurRadius: 6,
        color: color ?? ColorUtils.black.withOpacity(0.25),
      ),
    ];
