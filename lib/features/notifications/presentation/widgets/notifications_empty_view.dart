import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';

/// The inbox with nothing in it. Scrollable (inside the screen's
/// [RefreshIndicator]) so pull-to-refresh still works here.
class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 112.r,
                      height: 112.r,
                      decoration: BoxDecoration(
                        color: c.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 56.r,
                        color: c.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl.h),
                    Text(
                      Strings.notificationsEmptyTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h2(color: c.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    Text(
                      Strings.notificationsEmptyMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
