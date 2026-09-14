import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Placeholder delivery area — swap for the address the user actually
/// selected once that flow exists.
const String _placeholderAreaLabel = 'منطقة التوصيل: تربة';
const String _placeholderChangeAreaHint = 'تغيير المنطقة من العنوان';

/// The tinted "delivery area" strip under the Cart app bar.
///
/// TODO: open the address/area picker once that flow exists.
class CartDeliveryAreaBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const CartDeliveryAreaBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: c.secondaryLight,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: _placeholderAreaLabel,
                style: AppTextStyles.body(
                  color: c.textPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '  ·  $_placeholderChangeAreaHint',
                style: AppTextStyles.body(color: c.secondaryDark),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
