import 'package:document_reader/utils/AppColors.dart';
import 'package:flutter/material.dart';

LinearGradient commonGradient({Color? c1}) => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [c1 ?? ColorUtils.blue4FF, ColorUtils.primary],
    );
