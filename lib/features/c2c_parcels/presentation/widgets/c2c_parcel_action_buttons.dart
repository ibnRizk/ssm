import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/c2c_parcel.dart';
import '../cubit/c2c_parcel_tracking_cubit.dart';
import '../cubit/c2c_parcel_tracking_state.dart';
import 'c2c_parcel_sheets.dart';

/// The buttons the viewer may use right now. Each one's visibility comes
/// from [C2cParcelDetails] (role + status + the server's flags):
///
/// * show code — delivery code while out for delivery (or failed), the
///   sender's return code while returning;
/// * find a driver again — sender, after no driver was found;
/// * cancel — sender only, before pickup;
/// * support — while the server allows it.
class C2cParcelActionButtons extends StatelessWidget {
  final C2cParcelDetails parcel;

  const C2cParcelActionButtons({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final bool returnCode = parcel.status.allowsReturnOtp;
    return BlocSelector<
      C2cParcelTrackingCubit,
      C2cParcelTrackingState,
      C2cCommand?
    >(
      selector: (C2cParcelTrackingState state) =>
          state is C2cTrackingLoaded && state.command is C2cCommandInProgress
          ? (state.command as C2cCommandInProgress).command
          : null,
      builder: (BuildContext context, C2cCommand? running) {
        final bool busy = running != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (parcel.canRequestOtp) ...<Widget>[
              AppButton(
                btnText: returnCode
                    ? Strings.c2cTrackingReturnOtpButton
                    : Strings.c2cTrackingOtpButton,
                onPressed: () => C2cParcelSheets.showOtp(context),
              ),
              SizedBox(height: AppSpacing.sm.h),
            ],
            if (parcel.canRetryDispatch) ...<Widget>[
              AppButton(
                btnText: Strings.c2cTrackingRetryButton,
                isLoading: running == C2cCommand.retryDispatch,
                onPressed: busy
                    ? null
                    : context.read<C2cParcelTrackingCubit>().retryDispatch,
              ),
              SizedBox(height: AppSpacing.sm.h),
            ],
            if (parcel.canCancel)
              _TextAction(
                icon: Icons.cancel_outlined,
                label: Strings.c2cTrackingCancelButton,
                color: c.error,
                loading: running == C2cCommand.cancel,
                onPressed: busy
                    ? null
                    : () => C2cParcelSheets.showCancel(context),
              ),
            if (parcel.canOpenSupportCase)
              _TextAction(
                icon: Icons.support_agent,
                label: Strings.c2cTrackingSupportButton,
                color: c.primary,
                loading: running == C2cCommand.support,
                onPressed: busy
                    ? null
                    : () => C2cParcelSheets.showSupport(context),
              ),
          ],
        );
      },
    );
  }
}

class _TextAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  const _TextAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: loading
          ? SizedBox(
              width: 18.r,
              height: 18.r,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, color: color, size: 20.r),
      label: Text(label, style: AppTextStyles.titleSmall(color: color)),
    );
  }
}
