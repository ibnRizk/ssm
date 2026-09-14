import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';

void showAppSnackBar({
  required BuildContext context,
  required String message,
  required ToastType type,
  SnackBarBehavior? behavior = SnackBarBehavior.floating,
  Duration duration = const Duration(milliseconds: 2700),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    _buildAppSnackBar(
      context: context,
      message: message,
      type: type,
      behavior: behavior,
      duration: duration,
    ),
  );
}

SnackBar _buildAppSnackBar({
  required BuildContext context,
  required String message,
  required ToastType type,
  required SnackBarBehavior? behavior,
  required Duration duration,
}) {
  return SnackBar(
    content: _buildContent(context, message, type),
    dismissDirection: DismissDirection.horizontal,

    padding: _padding,
    margin: _getMargin(context, behavior),
    backgroundColor: type.color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    behavior: behavior,
    duration: duration,
    elevation: 0.0,
  );
}

Widget _buildContent(BuildContext context, String message, ToastType type) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: <Widget>[
      Icon(type.icon, color: colors.background, size: 32.r),
      SizedBox(width: 8.w),
      Text(
        message,
        style: TextStyle(
          color: colors.background,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          overflow: TextOverflow.clip,
        ),
      ),
    ],
  );
}

EdgeInsetsGeometry get _padding =>
    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);

EdgeInsetsGeometry? _getMargin(
  BuildContext context,
  SnackBarBehavior? behavior,
) {
  if (behavior != SnackBarBehavior.floating) {
    return null;
  }
  return EdgeInsetsDirectional.only(bottom: 16.h, start: 16.w, end: 16.w);
}

enum ToastType { success, error, warning, info }

extension ToastTypeColor on ToastType {
  Color get color {
    switch (this) {
      case ToastType.success:
        return _Colors.success;
      case ToastType.error:
        return _Colors.red;
      case ToastType.warning:
        return _Colors.warning;
      case ToastType.info:
        return _Colors.info;
    }
  }

  IconData get icon {
    switch (this) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
    }
  }
}

abstract class _Colors {
  static const Color success = Color(0xFF10A94B);
  static const Color red = Color(0xFFE63D35);
  static const Color info = Color(0xFF296CAF);
  static const Color warning = Color(0xFFF7B313);
}
