import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/load_more_status.dart';

/// The last row of a paginated list: a spinner while the next page loads,
/// a tap-to-retry row when it failed, nothing otherwise.
class LoadMoreFooter extends StatelessWidget {
  final LoadMoreStatus status;
  final VoidCallback onRetry;

  const LoadMoreFooter({
    super.key,
    required this.status,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return switch (status) {
      LoadMoreIdle() => const SizedBox.shrink(),
      LoadMoreInProgress() => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        child: const Center(child: CircularProgressIndicator()),
      ),
      LoadMoreFailed() => InkWell(
        onTap: onRetry,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
          child: Text(
            Strings.loadMoreFailed,
            style: AppTextStyles.body(color: c.error),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    };
  }
}
