import '../../../../core/api/json_readers.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/active_subscription.dart';

/// `GET /customer/c2c-parcels/subscriptions` → the customer's parcel plans
/// and their balances. The API guide names the endpoint but not its shape,
/// so the common spellings of each field are accepted, with or without a
/// `data` wrapper (and a paginated `data.data`).
abstract final class ParcelSubscriptionModel {
  /// Only usable, active subscriptions — an entry whose `status` is set to
  /// anything but `active`, or that has no remaining count, is skipped.
  /// Throws [ServerException] when the body holds no list.
  static List<ActiveSubscription> listFromJson(dynamic json) {
    final dynamic list = switch (json) {
      final List<dynamic> bare => bare,
      {'data': final List<dynamic> data} => data,
      {'data': {'data': final List<dynamic> page}} => page,
      _ => throw const ServerException(),
    };
    return list
        .map(_tryFromJson)
        .whereType<ActiveSubscription>()
        .toList(growable: false);
  }

  static ActiveSubscription? _tryFromJson(dynamic json) {
    if (json is! Map) return null;
    final String? status = jsonString(json['status'])?.toLowerCase();
    if (status != null && status != 'active') return null;

    final int? id = jsonInt(json['id']);
    final int? remaining =
        jsonInt(json['remaining_deliveries']) ??
        jsonInt(json['deliveries_remaining']);
    if (id == null || remaining == null) return null;

    final dynamic plan = json['plan'];
    final Map<dynamic, dynamic> planJson = plan is Map
        ? plan
        : const <dynamic, dynamic>{};
    final int total =
        jsonInt(json['deliveries_total']) ??
        jsonInt(json['total_deliveries']) ??
        jsonInt(json['deliveries_count']) ??
        jsonInt(planJson['deliveries_count']) ??
        remaining;

    return ActiveSubscription(
      id: id,
      deliveriesTotal: total,
      deliveriesRemaining: remaining,
      expiresAt: DateTime.tryParse(
        jsonString(json['expires_at']) ?? jsonString(json['ends_at']) ?? '',
      ),
      planName: jsonString(planJson['name']) ?? jsonString(json['plan_name']),
    );
  }
}
