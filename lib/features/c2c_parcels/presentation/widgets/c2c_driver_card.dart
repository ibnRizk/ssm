import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/launch_url_method.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/c2c_parcel.dart';

/// The driver once the viewer may see them: photo, name, a "live" hint
/// while their position is on the map, and a call button.
class C2cDriverCard extends StatelessWidget {
  final C2cDriver driver;
  final bool isLive;

  const C2cDriverCard({super.key, required this.driver, required this.isLive});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final String? phone = driver.phone;
    final double avatar = 44.r;
    return Container(
      decoration: AppDecorations.card(c),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Row(
        children: <Widget>[
          AppNetworkImage(
            url: driver.imageUrl,
            width: avatar,
            height: avatar,
            borderRadius: BorderRadius.circular(avatar),
            fallback: ColoredBox(
              color: c.primaryLight,
              child: Icon(Icons.person, color: c.primary),
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  driver.name ?? Strings.c2cTrackingDriver,
                  style: AppTextStyles.titleSmall(color: c.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  isLive
                      ? '${Strings.c2cTrackingDriver} · ${Strings.c2cTrackingDriverLive}'
                      : Strings.c2cTrackingDriver,
                  style: AppTextStyles.caption(
                    color: isLive ? c.success : c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (phone != null)
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: c.secondary),
              onPressed: () =>
                  makePhoneCall(phoneNumber: phone, context: context),
              icon: const Icon(Icons.call, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
