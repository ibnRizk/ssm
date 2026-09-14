import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: without a leading widget, centering the title in
/// the remaining space next to the "new" badge (a `Row` with an `Expanded`
/// middle) would put it visibly off-centre. Stacking full-width-aligned
/// layers centers the title on the whole header instead, the same trick
/// `AppBar.centerTitle` uses internally.
///
/// Parcels is a bottom-nav tab root, so — unlike a pushed screen — it must
/// not show a back button.
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
