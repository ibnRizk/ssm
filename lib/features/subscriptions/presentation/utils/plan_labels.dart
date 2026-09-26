import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/subscription_plan.dart';

extension SubscriptionPlanLabels on SubscriptionPlan {
  String get priceLabel => formatAmount(price);

  String get currencyLabel => currencySymbol(currency);

  String get summary =>
      Strings.subscriptionsPlanSummary(deliveriesCount, validityDays);
}
