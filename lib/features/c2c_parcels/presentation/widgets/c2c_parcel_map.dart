import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/geo_point.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/values/strings.dart';

/// Pickup, drop-off and the driver's live position. A new driver position
/// glides from the previous one instead of jumping, and the camera keeps
/// every point in view as points appear. The parent should rebuild it only
/// when [driver] (or an end) changes — see the tracking screen's map
/// selector.
class C2cParcelMap extends StatefulWidget {
  /// Null for a recipient (the server hides it).
  final GeoPoint? pickup;
  final GeoPoint? dropoff;

  /// Null while the viewer may not see the driver.
  final GeoPoint? driver;

  const C2cParcelMap({super.key, this.pickup, this.dropoff, this.driver});

  @override
  State<C2cParcelMap> createState() => _C2cParcelMapState();
}

class _C2cParcelMapState extends State<C2cParcelMap>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  late final AnimationController _glide;

  /// Where the driver marker starts and ends its current glide.
  LatLng? _from;
  LatLng? _to;

  /// Which points the camera last framed — reframed when that set changes.
  String? _framed;

  /// Each marker move crosses the platform channel, so the glide is drawn
  /// in steps of this length (~12 per glide) rather than on every vsync.
  static const Duration _glideStep = Duration(milliseconds: 100);

  /// When, into the current glide, the marker was last moved.
  Duration _lastStep = Duration.zero;

  /// Panning the map must not scroll the page around it.
  static final Set<Factory<OneSequenceGestureRecognizer>> _gestures =
      <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      };

  static const LatLng _fallbackCenter = LatLng(21.2146, 41.6330);

  @override
  void initState() {
    super.initState();
    _glide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(_onGlideTick);
    final GeoPoint? driver = widget.driver;
    if (driver != null) _from = _to = _latLng(driver);
  }

  void _onGlideTick() {
    final Duration elapsed = _glide.lastElapsedDuration ?? Duration.zero;
    if (!_glide.isCompleted && elapsed - _lastStep < _glideStep) return;
    _lastStep = elapsed;
    setState(() {});
  }

  @override
  void didUpdateWidget(C2cParcelMap old) {
    super.didUpdateWidget(old);
    final GeoPoint? driver = widget.driver;
    if (driver == null) {
      _from = _to = null;
    } else if (driver != old.driver) {
      // Start the next glide from wherever the marker is now.
      _from = _driverPosition ?? _latLng(driver);
      _to = _latLng(driver);
      _lastStep = Duration.zero;
      _glide.forward(from: 0);
    }
    _frameIfNeeded();
  }

  @override
  void dispose() {
    _glide.dispose();
    _controller?.dispose();
    super.dispose();
  }

  static LatLng _latLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  LatLng? get _driverPosition {
    final LatLng? from = _from;
    final LatLng? to = _to;
    if (from == null || to == null) return to;
    final double t = Curves.easeInOut.transform(_glide.value);
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  List<LatLng> get _points => <LatLng>[
    if (widget.pickup case final GeoPoint p) _latLng(p),
    if (widget.dropoff case final GeoPoint p) _latLng(p),
    if (widget.driver case final GeoPoint p) _latLng(p),
  ];

  void _frameIfNeeded() {
    final GoogleMapController? controller = _controller;
    final List<LatLng> points = _points;
    if (controller == null || points.isEmpty) return;
    final String key = <bool>[
      widget.pickup != null,
      widget.dropoff != null,
      widget.driver != null,
    ].join();
    if (key == _framed) return;
    _framed = key;
    if (points.length == 1) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 15));
      return;
    }
    double south = points.first.latitude, north = south;
    double west = points.first.longitude, east = west;
    for (final LatLng p in points.skip(1)) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        48,
      ),
    );
  }

  Set<Marker> _markers() {
    final LatLng? driver = _driverPosition;
    return <Marker>{
      if (widget.pickup case final GeoPoint p)
        Marker(
          markerId: const MarkerId('pickup'),
          position: _latLng(p),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: Strings.c2cTrackingPickupMarker),
        ),
      if (widget.dropoff case final GeoPoint p)
        Marker(
          markerId: const MarkerId('dropoff'),
          position: _latLng(p),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(title: Strings.c2cTrackingDropoffMarker),
        ),
      if (driver != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: driver,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          zIndexInt: 1,
          infoWindow: InfoWindow(title: Strings.c2cTrackingDriver),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> points = _points;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg.r),
      child: SizedBox(
        height: 220.h,
        // Each glide step ([_onGlideTick]) hands the map an updated marker
        // set; the plugin only moves the marker that changed.
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: points.isEmpty ? _fallbackCenter : points.first,
            zoom: 13,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            _frameIfNeeded();
          },
          markers: _markers(),
          gestureRecognizers: _gestures,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
      ),
    );
  }
}
