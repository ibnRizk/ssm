import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Soft, navy-tinted elevation. Deliberately subtle: cards only need to lift
/// off the light-gray background, not float.
abstract class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(color: Palette.shadowSoft, blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(
      color: Palette.shadowHairline,
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Casts upward — for bottom navigation and sticky checkout bars.
  static const List<BoxShadow> bottomBar = <BoxShadow>[
    BoxShadow(color: Palette.shadowSoft, blurRadius: 16, offset: Offset(0, -2)),
  ];
}

abstract class AppDecorations {
  /// Rounded card with [AppShadows.card], surfaced in the current theme's
  /// card colour by default (`c.surface` — white in light mode, dark gray in
  /// dark mode). Use for `Container` / `DecoratedBox` cards — Material's
  /// `Card` can't render a blurred shadow.
  static BoxDecoration card(
    AppColors c, {
    Color? color,
    double radius = AppRadius.lg,
  }) => BoxDecoration(
    color: color ?? c.surface,
    borderRadius: BorderRadius.circular(radius.r),
    boxShadow: AppShadows.card,
  );
}
