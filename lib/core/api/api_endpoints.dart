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
  static const String loyalty = '$_v1/customer/loyalty';
}
