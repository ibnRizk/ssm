import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/subscription_plan.dart';

extension SubscriptionPlanLabels on SubscriptionPlan {
  /// `100` for whole amounts, `99.50` otherwise.
  String get priceLabel => price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);

  /// Localized symbol for SAR; any other code is shown as sent.
  String get currencyLabel =>
      currency.toUpperCase() == 'SAR' ? Strings.currencySar : currency;

  String get summary =>
      Strings.subscriptionsPlanSummary(deliveriesCount, validityDays);
}
