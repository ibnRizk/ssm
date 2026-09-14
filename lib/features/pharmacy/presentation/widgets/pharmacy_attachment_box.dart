import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/dashed_border_box.dart';

/// The dashed-outline "attach the prescription photo" prompt.
///
/// TODO: wire to an image picker once that flow exists.
class PharmacyAttachmentBox extends StatelessWidget {
  final VoidCallback? onTap;

  const PharmacyAttachmentBox({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: DashedBorderBox(
        borderColor: c.secondary,
        backgroundColor: c.secondaryLight,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl.h),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.attach_file, color: c.secondary, size: 18.r),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                Strings.pharmacyAttachmentLabel,
                style: AppTextStyles.body(color: c.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
