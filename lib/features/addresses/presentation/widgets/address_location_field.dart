import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/address.dart';
import '../cubit/add_address_cubit.dart';
import '../cubit/add_address_state.dart';
import '../utils/address_messages.dart';

/// The address's GPS point, filled from the device location. Takes part in
/// the enclosing [Form] — submitting without a point shows "required" here.
///
/// Location problems — GPS off, access denied, or the point being outside
/// every delivery zone (403 `coordinates` on submit) — are shown inline
/// below the box, where the customer can retry.
class AddressLocationField extends StatelessWidget {
  const AddressLocationField({super.key});

  @override
  Widget build(BuildContext context) {
    return FormField<GeoPoint>(
      validator: (_) => context.read<AddAddressCubit>().state.location == null
          ? Strings.addressLocationRequired
          : null,
      builder: (FormFieldState<GeoPoint> field) =>
          BlocBuilder<AddAddressCubit, AddAddressState>(
            buildWhen: (AddAddressState previous, AddAddressState current) =>
                previous.location != current.location ||
                previous.failure != current.failure ||
                previous.isBusy != current.isBusy,
            builder: (BuildContext context, AddAddressState state) {
              final Failure? failure = state.failure;
              final String? error = failure != null && failure.isLocationProblem
                  ? failure.addressMessage
                  // Once a point is picked, the "required" error is stale.
                  : (state.location == null ? field.errorText : null);
              return _LocationBox(
                location: state.location,
                isLocating: state.status == AddAddressStatus.locating,
                enabled: !state.isBusy,
                error: error,
              );
            },
          ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final GeoPoint? location;
  final bool isLocating;
  final bool enabled;
  final String? error;

  const _LocationBox({
    required this.location,
    required this.isLocating,
    required this.enabled,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final GeoPoint? point = location;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg.r),
            border: Border.all(color: error != null ? c.error : c.border),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                point == null ? Icons.my_location : Icons.check_circle,
                size: 20.r,
                color: point == null ? c.textHint : c.success,
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: point == null
                    ? Text(
                        Strings.addressUseCurrentLocation,
                        style: AppTextStyles.body(color: c.textSecondary),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Strings.addressLocationPicked,
                            style: AppTextStyles.titleSmall(
                              color: c.textPrimary,
                            ),
                          ),
                          Text(
                            '${point.latitude.toStringAsFixed(5)}, '
                            '${point.longitude.toStringAsFixed(5)}',
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.caption(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
              if (isLocating)
                SizedBox(
                  width: 20.r,
                  height: 20.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton(
                  onPressed: enabled
                      ? () => context.read<AddAddressCubit>().locate()
                      : null,
                  style: TextButton.styleFrom(foregroundColor: c.secondary),
                  child: Text(
                    point == null
                        ? Strings.addressLocateButton
                        : Strings.addressUpdateLocation,
                  ),
                ),
            ],
          ),
        ),
        if (error case final String message)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.md.w,
              top: AppSpacing.xs.h,
            ),
            child: Text(message, style: AppTextStyles.caption(color: c.error)),
          ),
      ],
    );
  }
}
