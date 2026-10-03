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

  // --- App config (public) ---
  static const String customerConfig = '$_v1/config/customer';

  // --- Auth ---
  static const String login = '$_v1/auth/login';
  static const String signUp = '$_v1/auth/sign-up';

  /// Password recovery: request an OTP, verify it, then set the password.
  static const String forgotPassword = '$_v1/auth/forgot-password';
  static const String verifyResetToken = '$_v1/auth/verify-token';
  static const String resetPassword = '$_v1/auth/reset-password';

  // --- Customer ---
  static const String customerInfo = '$_v1/customer/info';
  static const String updateProfile = '$_v1/customer/update-profile';

  /// Refused with HTTP 203 (`on-going`) while an order is in progress.
  static const String removeAccount = '$_v1/customer/remove-account';

  // --- Loyalty ---
  static const String loyalty = '$_v1/customer/loyalty';
  static const String loyaltyHistory = '$_v1/customer/loyalty/history';

  // --- Addresses ---
  static const String addressList = '$_v1/customer/address/list';
  static const String addressAdd = '$_v1/customer/address/add';

  /// Takes the id as the `address_id` query parameter, not a path segment.
  static const String addressDelete = '$_v1/customer/address/delete';

  // --- Parcels ---
  static const String parcels = '$_v1/customer/parcels';
  static String parcelLocation(int parcelId) => '$parcels/$parcelId/location';

  // --- Zones ---
  static const String zoneList = '$_v1/zone/list';

  /// The zones covering the `lat` / `lng` query parameters.
  static const String zoneAt = '$_v1/config/get-zone-id';

  // --- Catalog (need the `zoneId` / `moduleId` headers) ---
  static const String categories = '$_v1/categories';

  /// The stores of one store type; paged like [allStores].
  static String categoryStores(int categoryId) =>
      '$categories/stores/$categoryId';

  /// `offset` is a 1-based page number, not a row offset.
  static const String allStores = '$_v1/stores/get-stores/all';
  static const String searchStores = '$_v1/stores/search';
  static String storeDetails(int storeId) => '$_v1/stores/details/$storeId';

  /// Filtered by the `store_id` / `category_id` query parameters.
  static const String latestItems = '$_v1/items/latest';

  // --- Cart (needs the zone headers) ---
  static const String cartList = '$_v1/customer/cart/list';
  static const String cartAdd = '$_v1/customer/cart/add';
  static const String cartUpdate = '$_v1/customer/cart/update';

  /// A DELETE whose `cart_id` goes in the JSON body.
  static const String cartRemoveItem = '$_v1/customer/cart/remove-item';

  // --- Orders (need the zone headers) ---
  static const String orderPlace = '$_v1/customer/order/place';

  /// Paginated like the store list: `offset` is a 1-based page number.
  static const String runningOrders = '$_v1/customer/order/running-orders';
  static const String orderHistory = '$_v1/customer/order/list';

  /// Legacy shapes; both take the id as the `order_id` query parameter.
  static const String orderDetails = '$_v1/customer/order/details';
  static const String orderTrack = '$_v1/customer/order/track';

  /// The SSM shape, with the canonical `ssm_status`.
  static String orderTracking(int orderId) =>
      '$_v1/customer/orders/$orderId/tracking';
  static String deliveryOtpRequest(int orderId) =>
      '$_v1/customer/orders/$orderId/delivery-otp/request';

  // --- Pharmacy requests ---
  /// Multipart: the prescription image travels as the `prescription` file.
  static const String pharmacyRequests = '$_v1/customer/pharmacy-requests';

  // --- Delivery subscriptions ---
  /// Takes the zone as the `zone_id` query parameter.
  static const String subscriptionPlans = '$_v1/customer/subscription-plans';
  static const String currentSubscription =
      '$_v1/customer/subscriptions/current';
  static const String subscriptionPurchaseIntent =
      '$_v1/customer/subscriptions/purchase-intent';
}
