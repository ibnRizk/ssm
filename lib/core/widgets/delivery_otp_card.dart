import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../delivery_otp/delivery_otp.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/failure_message.dart';
import '../utils/values/strings.dart';

/// The delivery code of an order or a parcel, big and spaced out so it can
/// be read aloud to the courier. [onRequest] fetches a code — a new one
/// replaces the old. [subtitle] tells codes apart when several show, e.g.
/// the parcel reference; [hint] replaces the order wording under the code,
/// and [title] the "delivery code" heading (e.g. for a return code).
class DeliveryOtpCard extends StatelessWidget {
  final DeliveryOtpState otp;
  final VoidCallback onRequest;
  final String? title;
  final String? subtitle;
  final String? hint;

  const DeliveryOtpCard({
    super.key,
    required this.otp,
    required this.onRequest,
    this.title,
    this.subtitle,
    this.hint,
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
                title ?? Strings.orderTrackingOtpTitle,
                style: AppTextStyles.title(color: c.textPrimary),
              ),
              if (subtitle case final String subtitle) ...<Widget>[
                SizedBox(width: AppSpacing.xs.w),
                Flexible(
                  child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(color: c.textSecondary),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          switch (otp) {
            OtpIdle() || OtpLoading() => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
              child: const CircularProgressIndicator(),
            ),
            OtpReady(:final DeliveryOtp otp) => _Code(
              otp: otp,
              hint: hint ?? Strings.orderTrackingOtpHint,
            ),
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
  final String hint;

  const _Code({required this.otp, required this.hint});

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
          hint,
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
