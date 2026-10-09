import 'package:equatable/equatable.dart';

/// Where tapping a notification leads — from a push (any app state) or an
/// inbox row. Resolved from the backend's `entity_type` / `entity_id`.
sealed class NotificationTarget extends Equatable {
  const NotificationTarget();

  /// Spellings vary across the backend (`order`, `orders`,
  /// `App\Models\Order`, `PharmacyRequest`, `pharmacy_request`), so the
  /// type is reduced to bare lowercase letters before matching. Anything
  /// unknown — or a known type without a usable id — opens the inbox,
  /// never a wrong screen.
  factory NotificationTarget.resolve({String? entityType, String? entityId}) {
    final String type = _normalize(entityType);
    final int? id = int.tryParse(entityId?.trim() ?? '');
    return switch (type) {
      'order' || 'orders' when id != null => OrderTarget(id),
      // `c2c_parcel` / `SsmC2cParcel` — digits are stripped, hence `cc`.
      'ccparcel' ||
      'ccparcels' ||
      'ssmccparcel' when id != null => C2cParcelTarget(id),
      'parcel' || 'parcels' => const ParcelsTarget(),
      'subscription' || 'subscriptions' => const SubscriptionsTarget(),
      _ => const InboxTarget(),
    };
  }

  static String _normalize(String? raw) {
    if (raw == null) return '';
    // Keep only the class name of a namespaced model (`App\Models\Order`).
    final String last = raw.split(RegExp(r'[\\/.]')).last;
    return last.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  }

  @override
  List<Object?> get props => [];
}

/// The order's tracking screen — the app's order-details screen.
final class OrderTarget extends NotificationTarget {
  final int orderId;

  const OrderTarget(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// One door-to-door parcel's tracking screen (`entity_type = c2c_parcel`).
final class C2cParcelTarget extends NotificationTarget {
  final int parcelId;

  const C2cParcelTarget(this.parcelId);

  @override
  List<Object?> get props => [parcelId];
}

/// The Parcels tab. Warehouse parcels have no single-parcel screen; the tab
/// lists them.
final class ParcelsTarget extends NotificationTarget {
  const ParcelsTarget();
}

final class SubscriptionsTarget extends NotificationTarget {
  const SubscriptionsTarget();
}

final class InboxTarget extends NotificationTarget {
  const InboxTarget();
}
