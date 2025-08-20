import 'dart:ui';

import 'package:dhanra/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Gradients {
  static Widget gradient({
    required double top,
    required double left,
    required double right,
    required BuildContext context,
  }) {
    return Positioned.fill(
      top: top,
      left: left,
      // right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Theme.of(context).primaryColor,
                AppColors.background,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
