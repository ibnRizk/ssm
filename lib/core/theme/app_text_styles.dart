import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';

/// Semantic type scale for SSM. Styles are named by role, not size — a screen
/// title is [h1] everywhere, so resizing it is a one-line change here.
///
/// [color] is optional: when omitted, text inherits its colour from the
/// ambient `DefaultTextStyle` / `ThemeData.textTheme`.
///
/// Cairo ships a very tall line box, so every style sets an explicit line
/// height with even leading to keep glyphs centred without bloating layouts.
abstract class AppTextStyles {
  static const double _headingHeight = 1.3;
  static const double _bodyHeight = 1.5;

  /// 28 · Bold — splash and hero brand text.
  static TextStyle display({Color? color}) =>
      _style(28, FontWeight.w700, _headingHeight, color);

  /// 24 · Bold — screen titles.
  static TextStyle h1({Color? color}) =>
      _style(24, FontWeight.w700, _headingHeight, color);

  /// 18 · Bold — section and sheet titles.
  static TextStyle h2({Color? color}) =>
      _style(18, FontWeight.w700, _headingHeight, color);

  /// 16 · Bold — store and card titles.
  static TextStyle title({Color? color}) =>
      _style(16, FontWeight.w700, _headingHeight, color);

  /// 14 · Bold — product and list-item names.
  static TextStyle titleSmall({Color? color}) =>
      _style(14, FontWeight.w700, _headingHeight, color);

  /// 16 · Medium — prominent body copy.
  static TextStyle bodyLarge({Color? color}) =>
      _style(16, FontWeight.w500, _bodyHeight, color);

  /// 14 · Medium — default body copy.
  static TextStyle body({Color? color}) =>
      _style(14, FontWeight.w500, _bodyHeight, color);

  /// 12 · Regular — meta lines, timestamps, helper text.
  static TextStyle caption({Color? color}) =>
      _style(12, FontWeight.w400, _bodyHeight, color);

  /// 11 · SemiBold — badges, chips, bottom-nav labels.
  static TextStyle label({Color? color}) =>
      _style(11, FontWeight.w600, _headingHeight, color);

  /// 16 · Bold — button labels.
  static TextStyle button({Color? color}) =>
      _style(16, FontWeight.w700, _headingHeight, color);

  static TextStyle _style(
    double size,
    FontWeight weight,
    double height,
    Color? color,
  ) => TextStyle(
    color: color,
    fontSize: size.sp,
    fontWeight: weight,
    fontFamily: AppFonts.primary,
    height: height,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
