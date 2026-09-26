import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/store.dart';

/// Display wording for a [Store], shared by the store card and the store
/// details header.
extension StoreLabels on Store {
  /// "Free delivery", "Delivery from 7 SAR", or null when the fee is unknown
  /// — it's only settled at checkout, from the distance.
  String? get deliveryFeeLabel {
    if (freeDelivery) return Strings.storeFreeDelivery;
    final double? fee = minimumDeliveryFee;
    if (fee == null) return null;
    if (fee == 0) return Strings.storeFreeDelivery;
    return Strings.storeDeliveryFrom(formatSar(fee));
  }

  /// The merchant's own wording (`30-40 min`), else the fastest delivery
  /// in minutes, else null.
  String? get deliveryTimeLabel {
    if (deliveryTime case final String time) return time;
    final int? minutes = minDeliveryTime;
    return minutes == null ? null : Strings.storeDeliveryMinutes(minutes);
  }

  /// Tags, else the address, for the line under the name.
  String? get subtitle => tags.isNotEmpty ? tags.join('  •  ') : address;
}
