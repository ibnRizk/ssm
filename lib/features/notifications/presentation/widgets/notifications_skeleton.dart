import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// The first load: row-shaped placeholders instead of a lone spinner, so
/// the list doesn't jump when it arrives.
class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  static const int _rows = 6;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.screen.r),
        itemCount: _rows,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm.h),
        itemBuilder: (_, int index) => Container(
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _block(c, width: 42.r, height: 42.r, radius: AppRadius.md),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Varied widths read as text, not as identical bars.
                    FractionallySizedBox(
                      widthFactor: index.isEven ? 0.7 : 0.5,
                      child: _block(c, height: 14.h),
                    ),
                    SizedBox(height: AppSpacing.xs.h),
                    _block(c, height: 12.h),
                    SizedBox(height: AppSpacing.xxs.h),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: _block(c, height: 12.h),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _block(
    AppColors c, {
    double? width,
    required double height,
    double radius = AppRadius.sm,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: c.border,
      borderRadius: BorderRadius.circular(radius.r),
    ),
  );
}
