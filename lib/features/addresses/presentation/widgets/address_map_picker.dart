import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/address.dart';
import '../cubit/add_address_cubit.dart';
import '../cubit/add_address_state.dart';

/// A map with a fixed pin at its centre: the customer drags the map until
/// the pin sits on their address. "Locate me" flies the camera to the GPS
/// position. Opens on the device location when it can get one.
class AddressMapPicker extends StatefulWidget {
  const AddressMapPicker({super.key});

  /// Shown until the first GPS fix — Turbah, the first delivery area.
  static const LatLng _fallbackCenter = LatLng(21.2146, 41.6330);
  static const double _overviewZoom = 13;
  static const double _streetZoom = 17;

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  GoogleMapController? _controller;

  /// The camera centre, tracked without rebuilding while the map moves.
  LatLng? _center;

  /// True between a finger touching the map and the camera settling — so a
  /// camera move *we* started (GPS fix, first frame) never counts as a pick.
  bool _userMoving = false;

  /// Panning the map must not scroll the form around it.
  static final Set<Factory<OneSequenceGestureRecognizer>> _gestures =
      <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      };

  @override
  void initState() {
    super.initState();
    final AddAddressCubit cubit = context.read<AddAddressCubit>();
    // Open on the customer's position rather than making them hunt for it.
    if (cubit.state.location == null) cubit.locate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onCameraIdle() {
    if (!_userMoving) return;
    _userMoving = false;
    final LatLng? center = _center;
    if (center == null) return;
    context.read<AddAddressCubit>().pickLocation(
      GeoPoint(latitude: center.latitude, longitude: center.longitude),
    );
  }

  void _flyTo(GeoPoint point) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(point.latitude, point.longitude),
        AddressMapPicker._streetZoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint? initial = context.read<AddAddressCubit>().state.location;
    return BlocListener<AddAddressCubit, AddAddressState>(
      // Only a fresh GPS fix moves the camera; a pin the customer placed is
      // already where the camera is.
      listenWhen: (AddAddressState previous, AddAddressState current) =>
          current.locationSource == LocationSource.device &&
          current.location != null &&
          current.location != previous.location,
      listener: (_, AddAddressState state) => _flyTo(state.location!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg.r),
        child: SizedBox(
          height: 240.h,
          child: Stack(
            children: <Widget>[
              Listener(
                onPointerDown: (_) => _userMoving = true,
                child: GoogleMap(
                  initialCameraPosition: initial == null
                      ? const CameraPosition(
                          target: AddressMapPicker._fallbackCenter,
                          zoom: AddressMapPicker._overviewZoom,
                        )
                      : CameraPosition(
                          target: LatLng(initial.latitude, initial.longitude),
                          zoom: AddressMapPicker._streetZoom,
                        ),
                  onMapCreated: (GoogleMapController controller) =>
                      _controller = controller,
                  onCameraMove: (CameraPosition position) =>
                      _center = position.target,
                  onCameraIdle: _onCameraIdle,
                  gestureRecognizers: _gestures,
                  // Our own "locate me" button asks for permission first;
                  // the SDK's blue dot and button would not.
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),
              ),
              const _CenterPin(),
              const PositionedDirectional(
                top: 12,
                end: 12,
                child: _LocateMeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pin's tip marks the map centre, so the icon is lifted by half its
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

class _LocateMeButton extends StatelessWidget {
  const _LocateMeButton();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return BlocSelector<AddAddressCubit, AddAddressState, (bool, bool)>(
      selector: (AddAddressState state) =>
          (state.status == AddAddressStatus.locating, state.isBusy),
      builder: (BuildContext context, (bool, bool) flags) {
        final (bool isLocating, bool isBusy) = flags;
        return Material(
          color: c.surface,
          shape: const CircleBorder(),
          elevation: 2,
          child: IconButton(
            tooltip: Strings.addressLocateButton,
            onPressed: isBusy
                ? null
                : () => context.read<AddAddressCubit>().locate(),
            icon: isLocating
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.my_location, color: c.secondary, size: 22.r),
          ),
        );
      },
    );
  }
}
