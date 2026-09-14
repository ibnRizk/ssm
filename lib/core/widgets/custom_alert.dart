import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';
import 'app_button.dart';

class CustomAlert {
  showAlertDialog({
    required BuildContext context,
    required Function() onpress,
    Function? onTap,
    required String title,
    required String subTitle,
    String? image,
    String? btnTitle,
    String? secondBtnTitle,
    Color? color,
    Color? secondColor,
    Color? secondTxtColor,
    bool viewSecondOption = false,
    bool isDismissible = true,
    double? btnRaduis,
    double? secondBtnRaduis,
  }) {
    Widget optionOne = SimpleDialogOption(
      child: AppButton(
        width: double.infinity,
        color: color,
        onPressed: onpress,
        btnText: btnTitle,
        borderRadius: btnRaduis,
      ),
    );
    Widget optionTwo = SimpleDialogOption(
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                width: double.infinity,
                color: color,
                onPressed: onpress,
                btnText: btnTitle,
                borderRadius: btnRaduis,
                borderColor: color,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppButton(
                color: secondColor ?? colors.primary,
                textColor: secondTxtColor ?? colors.textPrimary,
                onPressed: () => onTap ?? Navigator.pop(context),
                btnText: secondBtnTitle,
                borderRadius: secondBtnRaduis,
                borderColor: secondTxtColor,
              ),
            ),
          ],
        ),
      ),
    );
    // set up the SimpleDialog
    SimpleDialog dialog = SimpleDialog(
      surfaceTintColor: colors.background,
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0.r),
      ),
      titlePadding: const EdgeInsets.only(top: 8.0),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16.0),
          image != null
              ? SizedBox(
                  height: 100.h,
                  width: 100.w,
                  child: Image.asset(image, fit: BoxFit.scaleDown),
                )
              : const SizedBox(),
          SizedBox(height: image != null ? 16.0 : 0),
          if (title.isNotEmpty)
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: color, fontSize: 20.0.sp),
            ),
          SizedBox(height: 10.0.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              subTitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(fontSize: 16.h),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      children: <Widget>[!viewSecondOption ? optionOne : optionTwo],
    );

    // show the dialog
    showDialog(
      barrierDismissible: isDismissible,
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}
