import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/core/utils/extension.dart';
import '../../injection_container.dart';

class LoadingView extends StatelessWidget {
  final Color? bgColor;
  final Color? loadingColor;
  final double? height;
  final double? width;

  const LoadingView({
    super.key,
    this.height,
    this.width,
    this.bgColor,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    return Container(
      width: width ?? screenWidth,
      height: (height ?? 48.0).h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.textPrimary),
        color: bgColor ?? colors.primary,
      ),
      child: Center(
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(8.w),
          color: loadingColor ?? colors.surface,
        ).appLoading,
      ),
    );
  }
}
