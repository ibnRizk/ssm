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
import 'address_map_picker.dart';

/// The address's map pin. Takes part in the enclosing [Form] — submitting
/// without a pin shows "required" here.
///
/// Location problems — GPS off, access denied, or the pin being outside
/// every delivery zone (403 `coordinates` on submit) — are shown inline
/// below the map, where the customer can move the pin and retry.
class AddressLocationField extends StatelessWidget {
  const AddressLocationField({super.key});

  @override
  Widget build(BuildContext context) {
    return FormField<GeoPoint>(
      validator: (_) =>
          context.read<AddAddressCubit>().state.location ==
              null
          ? Strings.addressLocationRequired
          : null,
      builder: (FormFieldState<GeoPoint> field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const AddressMapPicker(),
          SizedBox(height: AppSpacing.xs.h),
          BlocBuilder<AddAddressCubit, AddAddressState>(
            buildWhen:
                (
                  AddAddressState previous,
                  AddAddressState current,
                ) =>
                    previous.location != current.location ||
                    previous.failure != current.failure,
            builder:
                (
                  BuildContext context,
                  AddAddressState state,
                ) {
                  final Failure? failure = state.failure;
                  final String? error =
                      failure != null &&
                          failure.isLocationProblem
                      ? failure.addressmssage
                      // Once a pin is placed, the "required" error is stale.
                      : (state.location == null
                            ? field.errorText
                            : null);
                  return _LocationStatus(
                    location: state.location,
                    error: error,
                  );
                },
          ),
        ],
      ),
    );
  }
}

/// One line under the map: the error, the picked coordinates, or a hint.
class _LocationStatus extends StatelessWidget {
  final GeoPoint? location;
  final String? error;

  const _LocationStatus({
    required this.location,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final GeoPoint? point = location;
    final (
      IconData icon,
      Color color,
      String text,
    ) = switch ((error, point)) {
      (final String message, _) => (
        Icons.error_outline,
        c.error,
        message,
      ),
      (null, final GeoPoint p) => (
        Icons.check_circle,
        c.success,
        '${Strings.addressLocationPicked} · '
            '${p.latitude.toStringAsFixed(5)}, '
            '${p.longitude.toStringAsFixed(5)}',
      ),
      (null, null) => (
        Icons.pan_tool_alt_outlined,
        c.textHint,
        Strings.addressMapHint,
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.xs.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16.r, color: color),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
