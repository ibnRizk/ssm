import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// Account tab's top row: centered title with a settings-gear button pinned
/// to the reading-end side.
///
/// No back button, unlike the design mock: like [OrdersHeader]/[HomeHeader],
/// this is a bottom-nav tab root, not a pushed screen, so there's nowhere to
/// go "back" to.
class AccountHeaderBar extends StatelessWidget {
  const AccountHeaderBar({super.key});

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
            Strings.accountTitle,
            style: AppTextStyles.h1(color: c.textPrimary),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              // TODO: open the app settings screen once it exists.
              onTap: () {},
              child: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: c.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: 18.r,
                  color: c.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
