import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';
import '../theme/app_text_styles.dart';

class ModalBottomSheetScaffold extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget child;

  const ModalBottomSheetScaffold({
    required this.title,
    this.subTitle = '',
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          topEnd: Radius.circular(24.r),
        ),
        color: colors.background,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          ///AppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.close_rounded,
                  size: 32.r,
                  color: Colors.transparent,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h2(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 32.r,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          subTitle.isNotEmpty
              ? Center(
                  child: Text(
                    subTitle,
                    style: AppTextStyles.body(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
          SizedBox(height: 16.h),

          ///Body
          child,
        ],
      ),
    );
  }
}
