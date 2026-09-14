import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool?> showAppDialog({
  required BuildContext context,
  required Widget child,
  double? borderRadius,
  bool isDismissible = true,
  double horizontalPadding = 40.0,
  double verticalPadding = 24.0,
  Color? backgroundColor,
}) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
        child: Dialog(
          insetAnimationDuration: Duration(seconds: 3),
          backgroundColor: backgroundColor ?? Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalPadding.w,
            vertical: verticalPadding.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          child: PopScope(
            onPopInvokedWithResult: (value, result) async => isDismissible,
            child: child,
          ),
        ),
      );
    },
  );
}
