import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/subscription_plan.dart';

extension SubscriptionPlanLabels on SubscriptionPlan {
  String get priceLabel => formatAmount(price);

  String get currencyLabel => currencySymbol(currency);

  /// Deliveries and validity, then a parcel plan's limits when it has any.
  String get summary => <String>[
    Strings.subscriptionsPlanSummary(deliveriesCount, validityDays),
    if (maxDistanceKm case final double km)
      Strings.subscriptionsPlanMaxDistance(formatAmount(km)),
    if (maxWeightKg case final double kg)
      Strings.subscriptionsPlanMaxWeight(formatAmount(kg)),
  ].join(' · ');
}
