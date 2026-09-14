import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';
import '../utils/values/text_styles.dart';

class AppOutlinedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Size? minimumSize, maximumSize;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? buttonRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final TextStyle? textStyle;
  final MainAxisAlignment? alignment;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.buttonRadius,
    this.icon,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
    this.textStyle,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        side: BorderSide(color: borderColor ?? colors.primary),
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius ?? 8.r),
        ),
        minimumSize: minimumSize,
        maximumSize: maximumSize,
      ),
      child: Center(
        child: Builder(
          builder: (BuildContext context) {
            if (icon != null) {
              return Row(
                mainAxisAlignment: alignment ?? MainAxisAlignment.center,
                children: [
                  icon!,
                  SizedBox(width: 8.w),
                  _text,
                ],
              );
            }
            return _text;
          },
        ),
      ),
    );
  }

  Widget get _text => Text(
    text,
    style: textStyle ?? TextStyles.medium16(color: textColor ?? colors.primary),
  );
}
