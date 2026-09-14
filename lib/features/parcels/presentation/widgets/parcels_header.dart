import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: the back button and the "new" badge are different
/// widths, so centering the title in the space *between* them (a `Row` with
/// an `Expanded` middle) would put it visibly off-centre. Stacking three
/// full-width-aligned layers centers the title on the whole header instead,
/// the same trick `AppBar.centerTitle` uses internally.
class ParcelsHeader extends StatelessWidget {
  const ParcelsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Text(
            Strings.parcelsTitle,
            style: AppTextStyles.h1(color: c.textPrimary),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              // Points toward the reading direction's "back" side — right
              // under RTL, left under LTR — rather than a fixed glyph.
              child: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward
                    : Icons.arrow_back,
                size: 18.r,
                color: c.textPrimary,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm.w,
                vertical: AppSpacing.xxs.h,
              ),
              decoration: BoxDecoration(
                color: c.secondaryLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                Strings.parcelsBadgeNew,
                style: AppTextStyles.label(color: c.secondaryDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
