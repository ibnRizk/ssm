import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/app_assets.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: the back button and the logo are different
/// widths, so centering the title in the space *between* them (a `Row` with
/// an `Expanded` middle) would put it visibly off-centre. Stacking three
/// full-width-aligned layers centers the title on the whole header instead —
/// the same trick [ParcelsHeader] uses.
class RestaurantsHeader extends StatelessWidget {
  /// E.g. the number of stores available; hidden while unknown.
  final String? subtitle;
  final VoidCallback? onBack;

  const RestaurantsHeader({super.key, this.subtitle, this.onBack});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                Strings.restaurantsTitle,
                style: AppTextStyles.h1(color: c.textPrimary),
              ),
              if (subtitle case final String subtitle) ...<Widget>[
                SizedBox(height: AppSpacing.xxs.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption(color: c.textSecondary),
                ),
              ],
            ],
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
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
                child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward
                      : Icons.arrow_back,
                  size: 18.r,
                  color: c.textPrimary,
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              width: 36.r,
              height: 36.r,
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                boxShadow: AppShadows.card,
              ),
              child: ClipOval(
                child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
