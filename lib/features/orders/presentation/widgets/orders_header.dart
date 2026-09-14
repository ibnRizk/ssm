import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// A [Stack], not a [Row]: the avatar and the count pill are different
/// widths, so centering the title in the space *between* them would put it
/// visibly off-centre — same trick [RestaurantsHeader] uses.
///
/// TODO: pull the user's real initial once auth is wired up — 'ع' is a
/// static placeholder for now (see [HomeHeader]'s equivalent TODO).
class OrdersHeader extends StatelessWidget {
  final int totalOrders;

  const OrdersHeader({super.key, required this.totalOrders});

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
            Strings.ordersTitle,
            style: AppTextStyles.h1(color: c.textPrimary),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'ع',
                    style: AppTextStyles.title(color: Colors.white),
                  ),
                ),
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
                color: c.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: c.border),
              ),
              child: Text(
                Strings.ordersCountLabel(totalOrders),
                style: AppTextStyles.label(color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
