import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Unlike [ParcelsHeader]/[RestaurantsHeader], the back button here sits on
/// its own row above the title block rather than straddling it — the title
/// and subtitle are simply start-aligned underneath, matching the design.
class PharmacyHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const PharmacyHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            // Points toward the reading direction's "back" side — right
            // under RTL, left under LTR — rather than a fixed glyph.
            child: Transform.flip(
              flipX:
                  Directionality.of(context) ==
                  TextDirection.rtl,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.r,
                color: c.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        Text(
          Strings.pharmacyTitle,
          style: AppTextStyles.h1(color: c.textPrimary),
        ),
        SizedBox(height: AppSpacing.xxs.h),
        Text(
          Strings.pharmacySubtitle,
          style: AppTextStyles.caption(
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}
