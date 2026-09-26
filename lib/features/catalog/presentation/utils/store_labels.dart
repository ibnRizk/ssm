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

  /// Tags, else the address, for the line under the name.
  String? get subtitle => tags.isNotEmpty ? tags.join('  •  ') : address;
}
