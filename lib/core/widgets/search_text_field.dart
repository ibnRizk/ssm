import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final String? labelText;
  final String? hintText;
  final bool autoComplete;
  final void Function()? onPressed;

  // Customization parameters
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? hintTextColor;
  final Color? borderColor;

  const MySearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmit,
    this.labelText,
    this.hintText,
    this.autoComplete = false,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.hintTextColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    double myFontSize = 14.sp;
    double radius = 12.r;

    final Color defaultColor = colors.textPrimary;

    return Container(
      width: ScreenUtil().screenWidth,
      alignment: Alignment.centerRight,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: onSubmit,
        onChanged: autoComplete ? onChanged : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: backgroundColor ?? colors.background,
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          hintStyle: theme.bodyMedium!.copyWith(
            color: hintTextColor ?? defaultColor,
            fontSize: myFontSize,
          ),
          prefixIcon: IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.search, color: iconColor ?? defaultColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: borderColor ?? defaultColor,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: borderColor ?? defaultColor,
              width: 2.0,
            ),
          ),
        ),
        style: theme.bodyMedium!.copyWith(
          color: defaultColor,
          fontSize: myFontSize,
        ),
      ),
    );
  }
}
