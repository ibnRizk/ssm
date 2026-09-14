import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/enums.dart';
import '../utils/values/app_colors.dart';
import '../utils/values/strings.dart';
import 'app_button.dart';

/// Full-screen error / empty state.
///
/// Deliberately has no opinion about routing or copy — pass [message] and an
/// optional [onRetry]. Supply [illustrationAsset] to show artwork; without one
/// it falls back to an icon so the boilerplate ships with no assets.
class ErrorText extends StatelessWidget {
  final String? message;
  final MyError kind;
  final String? illustrationAsset;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final bool wrapInScaffold;
  final EdgeInsetsGeometry? margin;

  const ErrorText({
    super.key,
    this.message,
    this.kind = MyError.defaultError,
    this.illustrationAsset,
    this.onRetry,
    this.retryLabel,
    this.wrapInScaffold = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildContent(context);
    if (!wrapInScaffold) return content;
    return Scaffold(body: SafeArea(child: content));
  }

  Widget _buildContent(BuildContext context) {
    final double side = MediaQuery.sizeOf(context).width * 0.45;

    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.all(24.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (illustrationAsset != null)
            SizedBox(
              width: side,
              height: side,
              child: Image.asset(illustrationAsset!),
            )
          else
            Icon(
              _fallbackIcon,
              size: 72.r,
              color: context.colors.textSecondary,
            ),
          SizedBox(height: 16.h),
          Text(
            message ?? Strings.somethingWentWrong,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: context.colors.textSecondary,
            ),
          ),
          if (onRetry != null) ...<Widget>[
            SizedBox(height: 24.h),
            AppButton(onPressed: onRetry, btnText: retryLabel ?? Strings.retry),
          ],
        ],
      ),
    );
  }

  IconData get _fallbackIcon => switch (kind) {
    MyError.search => Icons.search_off_outlined,
    MyError.notFound => Icons.inbox_outlined,
    MyError.defaultError => Icons.error_outline,
  };
}
