import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/location/geo_point.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../cubit/send_parcel_cubit.dart';
import '../cubit/send_parcel_state.dart';
import 'map_pin_picker_sheet.dart';

/// One end of the trip: a status line plus "on the map" / "my location".
/// Takes part in the enclosing [Form] — asking for a price without this
/// location shows "required" here.
class ParcelPointField extends StatelessWidget {
  final ParcelEnd end;

  const ParcelPointField({super.key, required this.end});

  Future<void> _pickOnMap(BuildContext context) async {
    final SendParcelCubit cubit = context.read<SendParcelCubit>();
    final SendParcelState state = cubit.state;
    // Start from this end, else the other one — both are usually nearby.
    final GeoPoint? start =
        state.pointOf(end) ??
        state.pointOf(
          end == ParcelEnd.pickup ? ParcelEnd.dropoff : ParcelEnd.pickup,
        );
    final GeoPoint? picked = await MapPinPickerSheet.show(
      context,
      initial: start,
    );
    if (picked != null) cubit.setPoint(end, picked);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<GeoPoint>(
      validator: (_) =>
          context.read<SendParcelCubit>().state.pointOf(end) == null
          ? Strings.sendParcelPointRequired
          : null,
      builder: (FormFieldState<GeoPoint> field) =>
          BlocSelector<
            SendParcelCubit,
            SendParcelState,
            (GeoPoint?, ParcelEnd?)
          >(
            selector: (SendParcelState state) =>
                (state.pointOf(end), state.locating),
            builder: (BuildContext context, (GeoPoint?, ParcelEnd?) slice) {
              final (GeoPoint? point, ParcelEnd? locating) = slice;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _PointButton(
                          icon: Icons.map_outlined,
                          label: Strings.sendParcelPickOnMap,
                          onPressed: locating == null
                              ? () => _pickOnMap(context)
                              : null,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: _PointButton(
                          icon: Icons.my_location,
                          label: Strings.sendParcelUseMyLocation,
                          isLoading: locating == end,
                          onPressed: locating == null
                              ? () => context
                                    .read<SendParcelCubit>()
                                    .useCurrentLocation(end)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  _PointStatus(
                    point: point,
                    // Once a point is set, the "required" error is stale.
                    error: point == null ? field.errorText : null,
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _PointButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PointButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        side: BorderSide(color: c.border),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
      ),
      icon: isLoading
          ? SizedBox(
              width: 16.r,
              height: 16.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 18.r, color: c.secondary),
      label: Text(label, style: AppTextStyles.body(color: c.textPrimary)),
    );
  }
}

/// One line under the buttons: the error, the set coordinates, or a hint.
class _PointStatus extends StatelessWidget {
  final GeoPoint? point;
  final String? error;

  const _PointStatus({required this.point, required this.error});

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final (IconData icon, Color color, String text) = switch ((error, point)) {
      (final String message, _) => (Icons.error_outline, c.error, message),
      (null, final GeoPoint p) => (
        Icons.check_circle,
        c.success,
        '${Strings.sendParcelPointPicked} · '
            '${p.latitude.toStringAsFixed(5)}, '
            '${p.longitude.toStringAsFixed(5)}',
      ),
      (null, null) => (
        Icons.location_searching,
        c.textHint,
        Strings.sendParcelPointHint,
      ),
    };
    return Padding(
      padding: EdgeInsetsDirectional.only(start: AppSpacing.xs.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16.r, color: color),
          SizedBox(width: AppSpacing.xs.w),
          Expanded(
            child: Text(text, style: AppTextStyles.caption(color: color)),
          ),
        ],
      ),
    );
  }
}
