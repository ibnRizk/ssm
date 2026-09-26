import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/location/geo_point.dart';
import '../../domain/entities/parcel.dart';

/// One entry of `GET /customer/parcels` → `{ "data": [...], "total_size" }`.
class ParcelModel extends Parcel {
  const ParcelModel({
    required super.id,
    required super.reference,
    required super.status,
    required super.paymentType,
    required super.codAmount,
    required super.deliveryFee,
    required super.currency,
    super.dropoffLocation,
    super.deliveryAddress,
    super.updatedAt,
  });

  /// Null for an entry without an id — it can't be tracked or updated.
  static ParcelModel? tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final int? id = jsonInt(json['id']);
    if (id == null) return null;
    final double? latitude = jsonDouble(json['latitude']);
    final double? longitude = jsonDouble(json['longitude']);
    return ParcelModel(
      id: id,
      reference:
          jsonString(json['tracking_number']) ??
          jsonString(json['parcel_number']) ??
          jsonString(json['reference']) ??
          jsonString(json['code']) ??
          '#$id',
      status: statusFromWire(jsonString(json['status'])),
      paymentType: jsonString(json['payment_type'])?.toUpperCase() == 'COD'
          ? ParcelPaymentType.cod
          : ParcelPaymentType.prepaid,
      codAmount: jsonDouble(json['cod_amount']) ?? 0,
      deliveryFee: jsonDouble(json['customer_delivery_fee']) ?? 0,
      currency: jsonString(json['customer_delivery_fee_currency']) ?? 'SAR',
      dropoffLocation: latitude == null || longitude == null
          ? null
          : GeoPoint(latitude: latitude, longitude: longitude),
      deliveryAddress: jsonString(json['delivery_address']),
      updatedAt: DateTime.tryParse(jsonString(json['updated_at']) ?? ''),
    );
  }

  /// Throws [ServerException] when the body has no `data` list.
  static List<ParcelModel> listFromJson(dynamic json) {
    final dynamic data = json is Map ? json['data'] : null;
    if (data is! List) throw const ServerException();
    return data
        .map(ParcelModel.tryFromJson)
        .whereType<ParcelModel>()
        .toList(growable: false);
  }

  /// The API guide doesn't list parcel statuses, so this accepts the likely
  /// spellings of each stage (including the order-flow names the backend
  /// uses elsewhere). Anything unrecognised reads as
  /// [ParcelStatus.processing] — never as a later stage than it is.
  static ParcelStatus statusFromWire(String? value) =>
      switch (value?.toLowerCase()) {
        'delivered' || 'completed' => ParcelStatus.delivered,
        'out_for_delivery' ||
        'picked_up' ||
        'driver_assigned' ||
        'driver_accepted' ||
        'assigned' ||
        'dispatched' ||
        'dispatching' ||
        'on_the_way' => ParcelStatus.outForDelivery,
        'at_warehouse' ||
        'arrived_at_warehouse' ||
        'in_warehouse' ||
        'received' ||
        'received_at_warehouse' ||
        'arrived' ||
        'ready_for_delivery' ||
        'awaiting_location' => ParcelStatus.atWarehouse,
        _ => ParcelStatus.processing,
      };
}
