import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The saved-address card: pin badge, neighborhood/street, and a "change"
/// link.
///
/// TODO: open the address picker once that flow exists.
class OrderConfirmationAddressCard extends StatelessWidget {
  final String neighborhood;
  final String streetDetails;
  final VoidCallback? onChange;

  const OrderConfirmationAddressCard({
    super.key,
    required this.neighborhood,
    required this.streetDetails,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: c.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: c.secondary, size: 20.r),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  neighborhood,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  streetDetails,
                  style: AppTextStyles.caption(color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          GestureDetector(
            onTap: onChange,
            child: Text(
              Strings.orderConfirmationChangeButton,
              style: AppTextStyles.titleSmall(color: c.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
