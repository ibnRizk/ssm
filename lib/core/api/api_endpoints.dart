/// Central endpoint registry — paths only.
///
/// The host comes from `AppEnv.baseUrl` (see `.env`) and is applied once as
/// `Dio.options.baseUrl`, so never put a full URL here.
///
/// Example:
/// ```dart
/// abstract class ApiEndpoints {
///   static const String login = '/api/v1/auth/login';
///   static const String users = '/api/v1/users';
///   static String userById(int id) => '$users/$id';
/// }
/// ```
abstract class ApiEndpoints {
  static const String _v1 = '/api/v1';

  // --- Auth ---
  static const String login = '$_v1/auth/login';
  static const String signUp = '$_v1/auth/sign-up';

  // --- Customer ---
  static const String customerInfo = '$_v1/customer/info';
  static const String updateProfile = '$_v1/customer/update-profile';

  // --- Loyalty ---
  static const String loyalty = '$_v1/customer/loyalty';
  static const String loyaltyHistory = '$_v1/customer/loyalty/history';

  // --- Addresses ---
  static const String addressList = '$_v1/customer/address/list';
  static const String addressAdd = '$_v1/customer/address/add';

  /// Takes the id as the `address_id` query parameter, not a path segment.
  static const String addressDelete = '$_v1/customer/address/delete';

  // --- Zones ---
  static const String zoneList = '$_v1/zone/list';

  // --- Delivery subscriptions ---
  /// Takes the zone as the `zone_id` query parameter.
  static const String subscriptionPlans = '$_v1/customer/subscription-plans';
  static const String currentSubscription =
      '$_v1/customer/subscriptions/current';
  static const String subscriptionPurchaseIntent =
      '$_v1/customer/subscriptions/purchase-intent';
}
