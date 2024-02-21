// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:document_reader/utils/common_linear_gradient.dart';

class GradientText extends StatelessWidget {
  const GradientText({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => commonGradient().createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child,
    );
  }
}

class GradientBorderWidget extends StatelessWidget {
  final Widget child;
  final List<Color> gradientColors;
  final double borderWidth;

  const GradientBorderWidget({
    super.key,
    required this.child,
    this.gradientColors = const [Colors.blue, Colors.green],
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent, width: borderWidth),
          borderRadius: BorderRadius.circular(10),
        ),
        gradient: commonGradient(),
      ),
      child: child,
    );
  }
}
