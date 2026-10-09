import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/geo_point.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_button.dart';

/// A full-height sheet with a fixed pin at the map's centre: the customer
/// drags the map until the pin sits on the spot, then confirms. Pops the
/// picked [GeoPoint], or null when dismissed.
///
/// Same centre-pin approach as the address map picker, minus its form
/// coupling — it only needs a start point and returns the pick.
class MapPinPickerSheet extends StatefulWidget {
  final GeoPoint? initial;

  const MapPinPickerSheet({super.key, this.initial});

  /// Shown when there's no start point — Turbah, the first delivery area.
  static const LatLng _fallbackCenter = LatLng(21.2146, 41.6330);
  static const double _overviewZoom = 13;
  static const double _streetZoom = 17;

  static Future<GeoPoint?> show(BuildContext context, {GeoPoint? initial}) =>
      showModalBottomSheet<GeoPoint>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        // Dragging must pan the map, not close the sheet.
        enableDrag: false,
        builder: (_) => MapPinPickerSheet(initial: initial),
      );

  @override
  State<MapPinPickerSheet> createState() => _MapPinPickerSheetState();
}

class _MapPinPickerSheetState extends State<MapPinPickerSheet> {
  GoogleMapController? _controller;

  /// The camera centre, tracked without rebuilding while the map moves.
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    final GeoPoint? initial = widget.initial;
    _center = initial == null
        ? MapPinPickerSheet._fallbackCenter
        : LatLng(initial.latitude, initial.longitude);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm.w,
            vertical: AppSpacing.xs.h,
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: c.textPrimary),
              ),
              Expanded(
                child: Text(
                  Strings.sendParcelMapTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title(color: c.textPrimary),
                ),
              ),
              // Balances the close button so the title stays centred.
              SizedBox(width: 48.r),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: widget.initial == null
                      ? MapPinPickerSheet._overviewZoom
                      : MapPinPickerSheet._streetZoom,
                ),
                onMapCreated: (GoogleMapController controller) =>
                    _controller = controller,
                onCameraMove: (CameraPosition position) =>
                    _center = position.target,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),
              const _CenterPin(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen.w,
            AppSpacing.md.h,
            AppSpacing.screen.w,
            AppSpacing.lg.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                Strings.sendParcelMapHint,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(color: c.textSecondary),
              ),
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                btnText: Strings.sendParcelMapConfirm,
                onPressed: () => Navigator.pop(
                  context,
                  GeoPoint(
                    latitude: _center.latitude,
                    longitude: _center.longitude,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The pin's tip marks the map centre, so the icon is lifted by its
/// height.
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    final double size = 44.r;
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: size),
          child: Icon(
            Icons.location_on,
            size: size,
            color: context.colors.secondary,
            shadows: const <Shadow>[
              Shadow(color: Colors.black26, blurRadius: 6),
            ],
          ),
        ),
      ),
    );
  }
}
