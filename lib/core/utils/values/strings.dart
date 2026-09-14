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

  // --- Home ---
  static const String _homeGreeting = 'home_greeting';
  static String get homeGreeting => _homeGreeting.tr;

  static const String _homeQuestion = 'home_question';
  static String get homeQuestion => _homeQuestion.tr;

  static const String _homeSearchHint = 'home_search_hint';
  static String get homeSearchHint => _homeSearchHint.tr;

  static const String _homeSubscriptionBadge = 'home_subscription_badge';
  static String get homeSubscriptionBadge => _homeSubscriptionBadge.tr;

  static const String _homeSubscriptionTitle = 'home_subscription_title';
  static String get homeSubscriptionTitle => _homeSubscriptionTitle.tr;

  static const String _homeSubscriptionSubtitle = 'home_subscription_subtitle';
  static String get homeSubscriptionSubtitle => _homeSubscriptionSubtitle.tr;

  static const String _homeCategoriesTitle = 'home_categories_title';
  static String get homeCategoriesTitle => _homeCategoriesTitle.tr;

  static const String _homeViewAll = 'home_view_all';
  static String get homeViewAll => _homeViewAll.tr;

  static const String _homeOffersTitle = 'home_offers_title';
  static String get homeOffersTitle => _homeOffersTitle.tr;

  static const String _homeOfferTitle = 'home_offer_title';
  static String get homeOfferTitle => _homeOfferTitle.tr;

  static const String _homeOfferSubtitle = 'home_offer_subtitle';
  static String get homeOfferSubtitle => _homeOfferSubtitle.tr;

  static const String _homeOfferButton = 'home_offer_button';
  static String get homeOfferButton => _homeOfferButton.tr;

  // --- Parcels ---
  static const String _parcelsTitle = 'parcels_title';
  static String get parcelsTitle => _parcelsTitle.tr;

  static const String _parcelsBadgeNew = 'parcels_badge_new';
  static String get parcelsBadgeNew => _parcelsBadgeNew.tr;

  static const String _parcelsActionTitle = 'parcels_action_title';
  static String get parcelsActionTitle => _parcelsActionTitle.tr;

  static const String _parcelsActionSubtitle = 'parcels_action_subtitle';
  static String get parcelsActionSubtitle => _parcelsActionSubtitle.tr;

  static const String _parcelsActionBody = 'parcels_action_body';
  static String get parcelsActionBody => _parcelsActionBody.tr;

  static const String _parcelsActionButton = 'parcels_action_button';
  static String get parcelsActionButton => _parcelsActionButton.tr;

  static const String _parcelsTrackingTitle = 'parcels_tracking_title';
  static String get parcelsTrackingTitle => _parcelsTrackingTitle.tr;

  static const String _parcelsUpdateNow = 'parcels_update_now';
  static String get parcelsUpdateNow => _parcelsUpdateNow.tr;

  static const String _parcelsStepArrivedTitle = 'parcels_step_arrived_title';
  static String get parcelsStepArrivedTitle => _parcelsStepArrivedTitle.tr;

  static const String _parcelsStepArrivedSubtitle =
      'parcels_step_arrived_subtitle';
  static String get parcelsStepArrivedSubtitle =>
      _parcelsStepArrivedSubtitle.tr;

  static const String _parcelsStepDeliveringTitle =
      'parcels_step_delivering_title';
  static String get parcelsStepDeliveringTitle =>
      _parcelsStepDeliveringTitle.tr;

  static const String _parcelsStepDeliveringSubtitle =
      'parcels_step_delivering_subtitle';
  static String get parcelsStepDeliveringSubtitle =>
      _parcelsStepDeliveringSubtitle.tr;

  static const String _parcelsStepDeliveredTitle =
      'parcels_step_delivered_title';
  static String get parcelsStepDeliveredTitle => _parcelsStepDeliveredTitle.tr;

  static const String _parcelsStepDeliveredSubtitle =
      'parcels_step_delivered_subtitle';
  static String get parcelsStepDeliveredSubtitle =>
      _parcelsStepDeliveredSubtitle.tr;

  static const String _parcelsPendingTitle = 'parcels_pending_title';
  static String get parcelsPendingTitle => _parcelsPendingTitle.tr;

  static const String _parcelsPendingSubtitle = 'parcels_pending_subtitle';
  static String get parcelsPendingSubtitle => _parcelsPendingSubtitle.tr;

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
