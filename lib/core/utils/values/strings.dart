import '../../../config/locale/app_localizations.dart';

/// Translation-key wrappers. Every getter must have a matching key in
/// `lang/en.json` **and** `lang/ar.json`, or it renders `"<key> not found"`.
///
/// Keep this file and the JSON files in lockstep — that is the whole contract.
abstract class Strings {
  // --- App ---
  static const String _appName = 'app_name';
  static String get appName => _appName.tr;

  // --- Common actions ---
  static const String _ok = 'ok';
  static String get ok => _ok.tr;

  static const String _cancel = 'cancel';
  static String get cancel => _cancel.tr;

  static const String _confirm = 'confirm';
  static String get confirm => _confirm.tr;

  static const String _retry = 'retry';
  static String get retry => _retry.tr;

  static const String _save = 'save';
  static String get save => _save.tr;

  static const String _delete = 'delete';
  static String get delete => _delete.tr;

  static const String _search = 'search';
  static String get search => _search.tr;

  static const String _loading = 'loading';
  static String get loading => _loading.tr;

  // --- Errors / empty states ---
  static const String _noInternetConnection = 'no_internet_connection';
  static String get noInternetConnection => _noInternetConnection.tr;

  static const String _somethingWentWrong = 'something_went_wrong';
  static String get somethingWentWrong => _somethingWentWrong.tr;

  static const String _requestCancelled = 'request_cancelled';
  static String get requestCancelled => _requestCancelled.tr;

  static const String _noDataFound = 'no_data_found';
  static String get noDataFound => _noDataFound.tr;

  static const String _noResults = 'no_results';
  static String get noResults => _noResults.tr;

  // --- Settings ---
  static const String _language = 'language';
  static String get language => _language.tr;

  static const String _english = 'english';
  static String get english => _english.tr;

  static const String _arabic = 'arabic';
  static String get arabic => _arabic.tr;

  static const String _settings = 'settings';
  static String get settings => _settings.tr;

  static const String _theme = 'theme';
  static String get theme => _theme.tr;

  // --- Bottom navigation ---
  static const String _navHome = 'nav_home';
  static String get navHome => _navHome.tr;

  static const String _navOrders = 'nav_orders';
  static String get navOrders => _navOrders.tr;

  static const String _navParcels = 'nav_parcels';
  static String get navParcels => _navParcels.tr;

  static const String _navSubscriptions = 'nav_subscriptions';
  static String get navSubscriptions => _navSubscriptions.tr;

  static const String _navProfile = 'nav_profile';
  static String get navProfile => _navProfile.tr;

  // --- Splash ---
  static const String _splashTagline = 'splash_tagline';
  static String get splashTagline => _splashTagline.tr;

  static const String _splashSubtitle = 'splash_subtitle';
  static String get splashSubtitle => _splashSubtitle.tr;

  static const String _splashLoading = 'splash_loading';
  static String get splashLoading => _splashLoading.tr;

  // --- Auth ---
  static const String _authWelcomeTitle = 'auth_welcome_title';
  static String get authWelcomeTitle => _authWelcomeTitle.tr;

  static const String _authWelcomeSubtitle = 'auth_welcome_subtitle';
  static String get authWelcomeSubtitle => _authWelcomeSubtitle.tr;

  static const String _authPhoneLabel = 'auth_phone_label';
  static String get authPhoneLabel => _authPhoneLabel.tr;

  static const String _authContinue = 'auth_continue';
  static String get authContinue => _authContinue.tr;

  static const String _authNoAccount = 'auth_no_account';
  static String get authNoAccount => _authNoAccount.tr;

  static const String _authCreateAccountLink = 'auth_create_account_link';
  static String get authCreateAccountLink => _authCreateAccountLink.tr;

  static const String _authTermsNotice = 'auth_terms_notice';
  static String get authTermsNotice => _authTermsNotice.tr;

  static const String _authRegisterTitle = 'auth_register_title';
  static String get authRegisterTitle => _authRegisterTitle.tr;

  static const String _authRegisterSubtitle = 'auth_register_subtitle';
  static String get authRegisterSubtitle => _authRegisterSubtitle.tr;

  static const String _authFullNameLabel = 'auth_full_name_label';
  static String get authFullNameLabel => _authFullNameLabel.tr;

  static const String _authFullNameHint = 'auth_full_name_hint';
  static String get authFullNameHint => _authFullNameHint.tr;

  static const String _authRegionLabel = 'auth_region_label';
  static String get authRegionLabel => _authRegionLabel.tr;

  static const String _authRegionHint = 'auth_region_hint';
  static String get authRegionHint => _authRegionHint.tr;

  static const String _authRegisterButton = 'auth_register_button';
  static String get authRegisterButton => _authRegisterButton.tr;

  static const String _authHaveAccount = 'auth_have_account';
  static String get authHaveAccount => _authHaveAccount.tr;

  static const String _authLoginLink = 'auth_login_link';
  static String get authLoginLink => _authLoginLink.tr;

  // --- Validation ---
  static const String _fieldRequired = 'field_required';
  static String get fieldRequired => _fieldRequired.tr;

  static const String _invalidEmail = 'invalid_email';
  static String get invalidEmail => _invalidEmail.tr;

  static const String _invalidPhone = 'invalid_phone';
  static String get invalidPhone => _invalidPhone.tr;

  static const String _invalidName = 'invalid_name';
  static String get invalidName => _invalidName.tr;

  static const String _invalidNumbers = 'invalid_numbers';
  static String get invalidNumbers => _invalidNumbers.tr;

  static const String _passwordTooShort = 'password_too_short';
  static String get passwordTooShort => _passwordTooShort.tr;

  static const String _passwordsDoNotMatch = 'passwords_do_not_match';
  static String get passwordsDoNotMatch => _passwordsDoNotMatch.tr;
}
