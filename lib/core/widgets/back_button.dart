import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '/injection_container.dart';

class CustomBackButton extends StatelessWidget {
  final double height;
  final double width;
  final double raduis;
  final bool? refresh;
  const CustomBackButton({
    super.key,
    this.height = 32,
    this.width = 32,
    this.raduis = 16,
    this.refresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context, refresh),
      child: Container(
        height: height.h,
        width: width.w,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(raduis.r),
          border: Border.all(
            color: colors.textPrimary.withValues(
              alpha: 0.2,
            ),
            width: 1.w,
          ),
        ),
        child: Transform.flip(
          flipX:
              Directionality.of(context) ==
              TextDirection.rtl,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.w,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// Container(
//                       height: 35.h,
//                       width: 35.w,
//                       decoration: BoxDecoration(
//                         color: MyColors.arrowBackGrey,
//                         borderRadius: BorderRadius.circular(6.0.r),
//                       ),
//                       child: Icon(Icons.arrow_back_ios_new_outlined,),
//                     ),
