import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/address.dart';

enum AddAddressStatus { idle, locating, submitting, success }

/// Where [AddAddressState.location] came from. Only a GPS fix moves the map
/// camera; a pin the customer placed already *is* where the camera is.
enum LocationSource { map, device }

/// One class rather than a sealed union: the picked [location] must survive
/// every status change (locating → idle → submitting → idle on a refusal),
/// which a union would have to copy through each case.
final class AddAddressState extends Equatable {
  final AddAddressStatus status;
  final GeoPoint? location;
  final LocationSource locationSource;

  /// The last locate or submit failure. Cleared when the next attempt
  /// starts.
  final Failure? failure;

  const AddAddressState({
    this.status = AddAddressStatus.idle,
    this.location,
    this.locationSource = LocationSource.map,
    this.failure,
  });

  bool get isBusy =>
      status == AddAddressStatus.locating ||
      status == AddAddressStatus.submitting;

  @override
  List<Object?> get props => [status, location, locationSource, failure];
}
