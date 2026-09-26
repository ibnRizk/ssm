import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/failure_message.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/order_tracking.dart';
import '../cubit/order_tracking_state.dart';

/// The delivery code, big and spaced out so it can be read aloud to the
/// courier. [onRequest] fetches a code — a new one replaces the old.
class OrderTrackingOtpCard extends StatelessWidget {
  final DeliveryOtpState otp;
  final VoidCallback onRequest;

  const OrderTrackingOtpCard({
    super.key,
    required this.otp,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card(
        c,
      ).copyWith(border: Border.all(color: c.secondary, width: 2)),
      padding: EdgeInsets.all(AppSpacing.md.r),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline, color: c.secondary, size: 20.r),
              SizedBox(width: AppSpacing.xs.w),
              Text(
                Strings.orderTrackingOtpTitle,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          switch (otp) {
            OtpIdle() || OtpLoading() => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
              child: const CircularProgressIndicator(),
            ),
            OtpReady(:final DeliveryOtp otp) => _Code(otp: otp),
            OtpUnavailable() => _Problem(
              message: Strings.orderTrackingOtpUnavailable,
            ),
            OtpFailed(:final failure) => _Problem(
              message:
                  '${Strings.orderTrackingOtpFailed} ${failure.userMessage}',
            ),
          },
          if (otp is! OtpIdle && otp is! OtpLoading)
            TextButton(
              onPressed: onRequest,
              child: Text(
                otp is OtpReady
                    ? Strings.orderTrackingOtpNewCode
                    : Strings.orderTrackingOtpRetry,
                style: AppTextStyles.titleSmall(color: c.secondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _Code extends StatelessWidget {
  final DeliveryOtp otp;

  const _Code({required this.otp});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final DateTime? expiresAt = otp.expiresAt;
    return Column(
      children: <Widget>[
        // Digits read left to right in every locale.
        Directionality(
          textDirection: TextDirection.ltr,
          child: SelectableText(
            otp.code.split('').join(' '),
            style: AppTextStyles.h1(
              color: c.primary,
            ).copyWith(fontSize: 34.sp, letterSpacing: 4),
          ),
        ),
        SizedBox(height: AppSpacing.xs.h),
        Text(
          Strings.orderTrackingOtpHint,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption(color: c.textSecondary),
        ),
        if (expiresAt != null)
          Text(
            Strings.orderTrackingOtpExpires(
              DateFormat.Hm().format(expiresAt.toLocal()),
            ),
            style: AppTextStyles.caption(color: c.textSecondary),
          ),
      ],
    );
  }
}

class _Problem extends StatelessWidget {
  final String message;

  const _Problem({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: AppTextStyles.body(color: context.colors.textSecondary),
    );
  }
}
