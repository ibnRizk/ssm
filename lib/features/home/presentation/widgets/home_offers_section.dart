import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// Placeholder zone + price — swap for the resolved delivery zone and a real
/// price once the offers/pricing feature exists (see the region picker on
/// Register for the same zone names).
const String _placeholderOfferLocation = 'تربة · 10 ر.س';

class HomeOffersSection extends StatelessWidget {
  const HomeOffersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Strings.homeOffersTitle,
                style: AppTextStyles.h2(color: c.textPrimary),
              ),
            ),
            Text(
              _placeholderOfferLocation,
              style: AppTextStyles.titleSmall(color: c.secondary),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),
        Container(
          decoration: AppDecorations.card(),
          padding: EdgeInsets.all(AppSpacing.md.r),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Strings.homeOfferTitle,
                      style: AppTextStyles.titleSmall(color: c.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.xxs.h),
                    Text(
                      Strings.homeOfferSubtitle,
                      style: AppTextStyles.caption(color: c.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              AppButton(
                btnText: Strings.homeOfferButton,
                onPressed: () => context.push(AppRoutes.pharmacyOrder),
                width: 118.w,
                height: 40,
                borderRadius: AppRadius.pill,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
