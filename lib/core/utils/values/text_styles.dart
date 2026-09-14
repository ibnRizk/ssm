import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'fonts.dart';

abstract class TextStyles {
  static const String? _font = Fonts.primary;

  //region:: Light
  static TextStyle light12({Color? color}) => TextStyle(
    color: color,
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    fontFamily: _font,
  );

  //endregion

  //region:: Regular
  static TextStyle regular22({Color? color}) => TextStyle(
    color: color,
    fontSize: 22.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );
  static TextStyle regular28({Color? color}) => TextStyle(
    color: color,
    fontSize: 28.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );
  static TextStyle regular20({Color? color}) => TextStyle(
    color: color,
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular18({Color? color}) => TextStyle(
    color: color,
    fontSize: 18.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular17({Color? color}) => TextStyle(
    color: color,
    fontSize: 17.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular16({Color? color}) => TextStyle(
    color: color,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular15({Color? color}) => TextStyle(
    color: color,
    fontSize: 15.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular14({Color? color}) => TextStyle(
    color: color,
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    fontFamily: _font,
  );

  static TextStyle regular13({Color? color}) => TextStyle(
    color: color,
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular12({Color? color}) => TextStyle(
    color: color,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static TextStyle regular10({Color? color}) => TextStyle(
    color: color,
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  //endregion

  //region:: Medium
  static TextStyle medium24({Color? color}) => TextStyle(
    color: color,
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium22({Color? color}) => TextStyle(
    color: color,
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium20({Color? color}) => TextStyle(
    color: color,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium18({Color? color}) => TextStyle(
    color: color,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium17({Color? color}) => TextStyle(
    color: color,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium16({Color? color}) => TextStyle(
    color: color,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium15({Color? color}) => TextStyle(
    color: color,
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium14({Color? color}) => TextStyle(
    color: color,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium13({Color? color}) => TextStyle(
    color: color,
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium12({Color? color}) => TextStyle(
    color: color,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  static TextStyle medium10({Color? color}) => TextStyle(
    color: color,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _font,
  );

  //endregion

  //region:: SemiBold
  static TextStyle semiBold40({Color? color}) => TextStyle(
    color: color,
    fontSize: 40.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold24({Color? color}) => TextStyle(
    color: color,
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold22({Color? color}) => TextStyle(
    color: color,
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold20({Color? color}) => TextStyle(
    color: color,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold18({Color? color}) => TextStyle(
    color: color,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold17({Color? color}) => TextStyle(
    color: color,
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold16({Color? color}) => TextStyle(
    color: color,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold15({Color? color}) => TextStyle(
    color: color,
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold14({Color? color}) => TextStyle(
    color: color,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  static TextStyle semiBold12({Color? color}) => TextStyle(
    color: color,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    fontFamily: _font,
  );

  //endregion

  //region:: Bold
  static TextStyle bold32({Color? color}) => TextStyle(
    color: color,
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle bold30({Color? color}) => TextStyle(
    color: color,
    fontSize: 30.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold24({Color? color}) => TextStyle(
    color: color,
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    fontFamily: _font,
    height: 44.98 / 24, // Converting line-height to Flutter's height factor
    letterSpacing: 0, // Default is 0, but explicitly setting it
  );

  static TextStyle bold22({Color? color}) => TextStyle(
    color: color,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold20({Color? color}) => TextStyle(
    color: color,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold19({Color? color}) => TextStyle(
    color: color,
    fontSize: 19.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold18({Color? color}) => TextStyle(
    color: color,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold17({Color? color}) => TextStyle(
    color: color,
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold16({Color? color}) => TextStyle(
    color: color,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle undelLineBold16({Color? color}) => TextStyle(
    color: color,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
    decoration: TextDecoration.underline,
  );

  static TextStyle bold15({Color? color}) => TextStyle(
    color: color,
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  static TextStyle bold14({Color? color}) => TextStyle(
    color: color,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle bold12({Color? color}) => TextStyle(
    color: color,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle bold10({Color? color}) => TextStyle(
    color: color,
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );

  //endregion

  //region:: UnderLine Regular
  static TextStyle underlineRegular20({Color? color}) => TextStyle(
    color: color,
    fontSize: 20.sp,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
    decoration: TextDecoration.underline,
  );
  //endregion
}
