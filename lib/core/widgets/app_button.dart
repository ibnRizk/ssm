import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/values/app_colors.dart';
import '../utils/values/text_styles.dart';

/// Primary filled button.
///
/// [btnText] is plain display text. Translate at the call site
/// (`Strings.save`) — the source treated it as a translation key by default,
/// which silently rendered `"<key> not found"` for any literal label.
class AppButton extends StatelessWidget {
  final String? btnText;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? width;
  final String? svgAsset;
  final TextStyle? textStyle;
  final double? borderRadius;
  final Color? borderColor;
  final bool isLoading;

  const AppButton({
    super.key,
    this.btnText,
    required this.onPressed,
    this.textStyle,
    this.color,
    this.textColor,
    this.height,
    this.width,
    this.svgAsset,
    this.borderRadius,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = color ?? context.colors.primary;
    final Color foreground = textColor ?? Colors.white;
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: (height ?? 48.0).h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: context.colors.border,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius?.r ?? 12.r),
            side: BorderSide(color: borderColor ?? background),
          ),
        ),
        onPressed: disabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 22.r,
                height: 22.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: foreground,
                ),
              )
            : _buildLabel(foreground),
      ),
    );
  }

  Widget _buildLabel(Color foreground) {
    final Text label = Text(
      btnText ?? '',
      textAlign: TextAlign.center,
      style: textStyle ?? TextStyles.semiBold18(color: foreground),
    );

    if (svgAsset == null) return label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          svgAsset!,
          height: 24.h,
          width: 24.w,
          colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
        ),
        SizedBox(width: 6.w),
        label,
      ],
    );
  }
}
