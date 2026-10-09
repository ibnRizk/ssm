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

  static const String _splashUpdateTitle = 'splash_update_title';
  static String get splashUpdateTitle => _splashUpdateTitle.tr;

  static const String _splashUpdateMessage = 'splash_update_message';
  static String get splashUpdateMessage => _splashUpdateMessage.tr;

  static const String _splashUpdateButton = 'splash_update_button';
  static String get splashUpdateButton => _splashUpdateButton.tr;

  static const String _splashMaintenanceTitle = 'splash_maintenance_title';
  static String get splashMaintenanceTitle => _splashMaintenanceTitle.tr;

  static const String _splashMaintenanceMessage = 'splash_maintenance_message';
  static String get splashMaintenanceMessage => _splashMaintenanceMessage.tr;

  // --- Auth ---
  static const String _authWelcomeTitle = 'auth_welcome_title';
  static String get authWelcomeTitle => _authWelcomeTitle.tr;

  static const String _authWelcomeSubtitle = 'auth_welcome_subtitle';
  static String get authWelcomeSubtitle => _authWelcomeSubtitle.tr;

  static const String _authPhoneLabel = 'auth_phone_label';
  static String get authPhoneLabel => _authPhoneLabel.tr;

  static const String _authPasswordLabel = 'auth_password_label';
  static String get authPasswordLabel => _authPasswordLabel.tr;

  static const String _authPasswordHint = 'auth_password_hint';
  static String get authPasswordHint => _authPasswordHint.tr;

  static const String _authShowPassword = 'auth_show_password';
  static String get authShowPassword => _authShowPassword.tr;

  static const String _authHidePassword = 'auth_hide_password';
  static String get authHidePassword => _authHidePassword.tr;

  static const String _authLoginButton = 'auth_login_button';
  static String get authLoginButton => _authLoginButton.tr;

  static const String _authInvalidCredentials = 'auth_invalid_credentials';
  static String get authInvalidCredentials => _authInvalidCredentials.tr;

  static const String _authTooManyAttempts = 'auth_too_many_attempts';
  static String get authTooManyAttempts => _authTooManyAttempts.tr;

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

  static const String _authEmailLabel = 'auth_email_label';
  static String get authEmailLabel => _authEmailLabel.tr;

  static const String _authEmailHint = 'auth_email_hint';
  static String get authEmailHint => _authEmailHint.tr;

  static const String _authNewPasswordHint = 'auth_new_password_hint';
  static String get authNewPasswordHint => _authNewPasswordHint.tr;

  static const String _authRegisterButton = 'auth_register_button';
  static String get authRegisterButton => _authRegisterButton.tr;

  static const String _authHaveAccount = 'auth_have_account';
  static String get authHaveAccount => _authHaveAccount.tr;

  static const String _authLoginLink = 'auth_login_link';
  static String get authLoginLink => _authLoginLink.tr;

  // --- Forgot password ---
  static const String _authForgotPasswordLink = 'auth_forgot_password_link';
  static String get authForgotPasswordLink => _authForgotPasswordLink.tr;

  static const String _forgotPasswordTitle = 'forgot_password_title';
  static String get forgotPasswordTitle => _forgotPasswordTitle.tr;

  static const String _forgotPasswordPhoneSubtitle =
      'forgot_password_phone_subtitle';
  static String get forgotPasswordPhoneSubtitle =>
      _forgotPasswordPhoneSubtitle.tr;

  static const String _forgotPasswordSendCode = 'forgot_password_send_code';
  static String get forgotPasswordSendCode => _forgotPasswordSendCode.tr;

  static const String _forgotPasswordPhoneNotFound =
      'forgot_password_phone_not_found';
  static String get forgotPasswordPhoneNotFound =>
      _forgotPasswordPhoneNotFound.tr;

  static const String _forgotPasswordCodeTitle = 'forgot_password_code_title';
  static String get forgotPasswordCodeTitle => _forgotPasswordCodeTitle.tr;

  static const String _forgotPasswordCodeSubtitle =
      'forgot_password_code_subtitle';

  /// `{phone}` in the translation is replaced with the number the code was
  /// sent to.
  static String forgotPasswordCodeSubtitle(String phone) =>
      _forgotPasswordCodeSubtitle.tr.replaceFirst('{phone}', phone);

  static const String _forgotPasswordCodeLabel = 'forgot_password_code_label';
  static String get forgotPasswordCodeLabel => _forgotPasswordCodeLabel.tr;

  static const String _forgotPasswordInvalidCode =
      'forgot_password_invalid_code';
  static String get forgotPasswordInvalidCode => _forgotPasswordInvalidCode.tr;

  static const String _forgotPasswordVerifyButton =
      'forgot_password_verify_button';
  static String get forgotPasswordVerifyButton =>
      _forgotPasswordVerifyButton.tr;

  static const String _forgotPasswordResend = 'forgot_password_resend';
  static String get forgotPasswordResend => _forgotPasswordResend.tr;

  static const String _forgotPasswordCodeResent = 'forgot_password_code_resent';
  static String get forgotPasswordCodeResent => _forgotPasswordCodeResent.tr;

  static const String _forgotPasswordNewTitle = 'forgot_password_new_title';
  static String get forgotPasswordNewTitle => _forgotPasswordNewTitle.tr;

  static const String _forgotPasswordNewSubtitle =
      'forgot_password_new_subtitle';
  static String get forgotPasswordNewSubtitle => _forgotPasswordNewSubtitle.tr;

  static const String _forgotPasswordConfirmLabel =
      'forgot_password_confirm_label';
  static String get forgotPasswordConfirmLabel =>
      _forgotPasswordConfirmLabel.tr;

  static const String _forgotPasswordSaveButton = 'forgot_password_save_button';
  static String get forgotPasswordSaveButton => _forgotPasswordSaveButton.tr;

  static const String _forgotPasswordSuccess = 'forgot_password_success';
  static String get forgotPasswordSuccess => _forgotPasswordSuccess.tr;

  // --- Home ---
  static const String _homeGreeting = 'home_greeting';
  static String homeGreeting(String name) =>
      _homeGreeting.tr.replaceFirst('{name}', name);

  /// When the customer's name isn't known.
  static const String _homeGreetingGeneric = 'home_greeting_generic';
  static String get homeGreetingGeneric => _homeGreetingGeneric.tr;

  static const String _homeQuestion = 'home_question';
  static String get homeQuestion => _homeQuestion.tr;

  static const String _homeSearchHint = 'home_search_hint';
  static String get homeSearchHint => _homeSearchHint.tr;

  static const String _homeCategoriesTitle = 'home_categories_title';
  static String get homeCategoriesTitle => _homeCategoriesTitle.tr;

  static const String _homeViewAll = 'home_view_all';
  static String get homeViewAll => _homeViewAll.tr;

  static const String _homePharmacyCategory = 'home_pharmacy_category';
  static String get homePharmacyCategory => _homePharmacyCategory.tr;

  static const String _homeStoresTitle = 'home_stores_title';
  static String get homeStoresTitle => _homeStoresTitle.tr;

  static const String _homeStoresEmpty = 'home_stores_empty';
  static String get homeStoresEmpty => _homeStoresEmpty.tr;

  // --- Featured store promotions ---
  static const String _featuredStore = 'featured_store';
  static String get featuredStore => _featuredStore.tr;

  static const String _featuredStoreVideo = 'featured_store_video';
  static String get featuredStoreVideo => _featuredStoreVideo.tr;

  static const String _featuredStoreCta = 'featured_store_cta';
  static String get featuredStoreCta => _featuredStoreCta.tr;

  // --- Parcels ---
  static const String _parcelsTitle = 'parcels_title';
  static String get parcelsTitle => _parcelsTitle.tr;

  static const String _parcelsBadgeNew = 'parcels_badge_new';

  /// `{count}` in the translation is replaced with the parcels waiting for
  /// the customer's location.
  static String parcelsBadgeNew(int count) =>
      _parcelsBadgeNew.tr.replaceFirst('{count}', '$count');

  static const String _parcelsActionTitle = 'parcels_action_title';
  static String get parcelsActionTitle => _parcelsActionTitle.tr;

  static const String _parcelsShipmentReference = 'parcels_shipment_reference';

  /// `{reference}` in the translation is replaced with e.g. `SSM-P2048`.
  static String parcelsShipmentReference(String reference) =>
      _parcelsShipmentReference.tr.replaceFirst('{reference}', reference);

  static const String _parcelsActionBody = 'parcels_action_body';
  static String get parcelsActionBody => _parcelsActionBody.tr;

  static const String _parcelsActionBodySent = 'parcels_action_body_sent';
  static String get parcelsActionBodySent => _parcelsActionBodySent.tr;

  static const String _parcelsActionButton = 'parcels_action_button';
  static String get parcelsActionButton => _parcelsActionButton.tr;

  static const String _parcelsActionButtonUpdate =
      'parcels_action_button_update';
  static String get parcelsActionButtonUpdate => _parcelsActionButtonUpdate.tr;

  static const String _parcelsDropoffSheetSubtitle =
      'parcels_dropoff_sheet_subtitle';
  static String get parcelsDropoffSheetSubtitle =>
      _parcelsDropoffSheetSubtitle.tr;

  static const String _parcelsDropoffNotesLabel = 'parcels_dropoff_notes_label';
  static String get parcelsDropoffNotesLabel => _parcelsDropoffNotesLabel.tr;

  static const String _parcelsDropoffNotesHint = 'parcels_dropoff_notes_hint';
  static String get parcelsDropoffNotesHint => _parcelsDropoffNotesHint.tr;

  static const String _parcelsDropoffConfirm = 'parcels_dropoff_confirm';
  static String get parcelsDropoffConfirm => _parcelsDropoffConfirm.tr;

  static const String _parcelsDropoffSent = 'parcels_dropoff_sent';
  static String get parcelsDropoffSent => _parcelsDropoffSent.tr;

  static const String _parcelsEmpty = 'parcels_empty';
  static String get parcelsEmpty => _parcelsEmpty.tr;

  static const String _parcelsOtpHint = 'parcels_otp_hint';
  static String get parcelsOtpHint => _parcelsOtpHint.tr;

  static const String _parcelsPaymentPrepaid = 'parcels_payment_prepaid';
  static String get parcelsPaymentPrepaid => _parcelsPaymentPrepaid.tr;

  static const String _parcelsPaymentCod = 'parcels_payment_cod';

  /// `{amount}` and `{currency}` in the translation are replaced with the
  /// cash-on-delivery amount due.
  static String parcelsPaymentCod(String amount, String currency) =>
      _parcelsPaymentCod.tr
          .replaceFirst('{amount}', amount)
          .replaceFirst('{currency}', currency);

  static const String _parcelsFreeDelivery = 'parcels_free_delivery';
  static String get parcelsFreeDelivery => _parcelsFreeDelivery.tr;

  static const String _parcelsUpdatedJustNow = 'parcels_updated_just_now';
  static String get parcelsUpdatedJustNow => _parcelsUpdatedJustNow.tr;

  static const String _parcelsUpdatedMinutesAgo = 'parcels_updated_minutes_ago';

  /// `{count}` in the translation is replaced with the minutes elapsed.
  static String parcelsUpdatedMinutesAgo(int count) =>
      _parcelsUpdatedMinutesAgo.tr.replaceFirst('{count}', '$count');

  static const String _parcelsUpdatedHoursAgo = 'parcels_updated_hours_ago';

  /// `{count}` in the translation is replaced with the hours elapsed.
  static String parcelsUpdatedHoursAgo(int count) =>
      _parcelsUpdatedHoursAgo.tr.replaceFirst('{count}', '$count');

  static const String _parcelsUpdatedOn = 'parcels_updated_on';

  /// `{date}` in the translation is replaced with the formatted date.
  static String parcelsUpdatedOn(String date) =>
      _parcelsUpdatedOn.tr.replaceFirst('{date}', date);

  static const String _parcelsStepDeliveringLocationSent =
      'parcels_step_delivering_location_sent';
  static String get parcelsStepDeliveringLocationSent =>
      _parcelsStepDeliveringLocationSent.tr;

  static const String _parcelsStepDeliveringOnTheWay =
      'parcels_step_delivering_on_the_way';
  static String get parcelsStepDeliveringOnTheWay =>
      _parcelsStepDeliveringOnTheWay.tr;

  static const String _parcelsStepDeliveredDone = 'parcels_step_delivered_done';
  static String get parcelsStepDeliveredDone => _parcelsStepDeliveredDone.tr;

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

  static const String _parcelsSendButton = 'parcels_send_button';
  static String get parcelsSendButton => _parcelsSendButton.tr;

  // --- Send a door-to-door parcel ---
  static const String _sendParcelTitle = 'send_parcel_title';
  static String get sendParcelTitle => _sendParcelTitle.tr;

  static const String _sendParcelPickupLabel = 'send_parcel_pickup_label';
  static String get sendParcelPickupLabel => _sendParcelPickupLabel.tr;

  static const String _sendParcelDropoffLabel = 'send_parcel_dropoff_label';
  static String get sendParcelDropoffLabel => _sendParcelDropoffLabel.tr;

  static const String _sendParcelPointHint = 'send_parcel_point_hint';
  static String get sendParcelPointHint => _sendParcelPointHint.tr;

  static const String _sendParcelPointPicked = 'send_parcel_point_picked';
  static String get sendParcelPointPicked => _sendParcelPointPicked.tr;

  static const String _sendParcelPointRequired = 'send_parcel_point_required';
  static String get sendParcelPointRequired => _sendParcelPointRequired.tr;

  static const String _sendParcelPickOnMap = 'send_parcel_pick_on_map';
  static String get sendParcelPickOnMap => _sendParcelPickOnMap.tr;

  static const String _sendParcelUseMyLocation = 'send_parcel_use_my_location';
  static String get sendParcelUseMyLocation => _sendParcelUseMyLocation.tr;

  static const String _sendParcelMapTitle = 'send_parcel_map_title';
  static String get sendParcelMapTitle => _sendParcelMapTitle.tr;

  static const String _sendParcelMapHint = 'send_parcel_map_hint';
  static String get sendParcelMapHint => _sendParcelMapHint.tr;

  static const String _sendParcelMapConfirm = 'send_parcel_map_confirm';
  static String get sendParcelMapConfirm => _sendParcelMapConfirm.tr;

  static const String _sendParcelSizeLabel = 'send_parcel_size_label';
  static String get sendParcelSizeLabel => _sendParcelSizeLabel.tr;

  static const String _sendParcelWeightLabel = 'send_parcel_weight_label';
  static String get sendParcelWeightLabel => _sendParcelWeightLabel.tr;

  static const String _sendParcelWeightHint = 'send_parcel_weight_hint';
  static String get sendParcelWeightHint => _sendParcelWeightHint.tr;

  static const String _sendParcelWeightInvalid = 'send_parcel_weight_invalid';
  static String get sendParcelWeightInvalid => _sendParcelWeightInvalid.tr;

  static const String _sendParcelContentLabel = 'send_parcel_content_label';
  static String get sendParcelContentLabel => _sendParcelContentLabel.tr;

  static const String _sendParcelContentHint = 'send_parcel_content_hint';
  static String get sendParcelContentHint => _sendParcelContentHint.tr;

  static const String _sendParcelFragile = 'send_parcel_fragile';
  static String get sendParcelFragile => _sendParcelFragile.tr;

  static const String _sendParcelQuoteButton = 'send_parcel_quote_button';
  static String get sendParcelQuoteButton => _sendParcelQuoteButton.tr;

  static const String _sendParcelSummaryTitle = 'send_parcel_summary_title';
  static String get sendParcelSummaryTitle => _sendParcelSummaryTitle.tr;

  static const String _sendParcelDeliveryFee = 'send_parcel_delivery_fee';
  static String get sendParcelDeliveryFee => _sendParcelDeliveryFee.tr;

  static const String _sendParcelPlanDiscount = 'send_parcel_plan_discount';
  static String get sendParcelPlanDiscount => _sendParcelPlanDiscount.tr;

  static const String _sendParcelTotal = 'send_parcel_total';
  static String get sendParcelTotal => _sendParcelTotal.tr;

  static const String _sendParcelDistance = 'send_parcel_distance';

  /// `{km}` in the translation is replaced with the trip distance.
  static String sendParcelDistance(String km) =>
      _sendParcelDistance.tr.replaceFirst('{km}', km);

  static const String _sendParcelDiscountApplied =
      'send_parcel_discount_applied';

  /// `{remaining}` in the translation is replaced with the deliveries left
  /// on the applied plan.
  static String sendParcelDiscountApplied(int remaining) =>
      _sendParcelDiscountApplied.tr.replaceFirst('{remaining}', '$remaining');

  /// When the server applied a plan without saying how much is left on it.
  static const String _sendParcelDiscountAppliedNoCount =
      'send_parcel_discount_applied_no_count';
  static String get sendParcelDiscountAppliedNoCount =>
      _sendParcelDiscountAppliedNoCount.tr;

  static const String _sendParcelQuoteHeld = 'send_parcel_quote_held';
  static String get sendParcelQuoteHeld => _sendParcelQuoteHeld.tr;

  static const String _sendParcelConfirmButton = 'send_parcel_confirm_button';
  static String get sendParcelConfirmButton => _sendParcelConfirmButton.tr;

  // --- Door-to-door parcels ---
  static const String _sendParcelCategoryDocuments =
      'send_parcel_category_documents';
  static String get sendParcelCategoryDocuments =>
      _sendParcelCategoryDocuments.tr;

  static const String _sendParcelCategorySmall = 'send_parcel_category_small';
  static String get sendParcelCategorySmall => _sendParcelCategorySmall.tr;

  static const String _sendParcelCategoryMedium = 'send_parcel_category_medium';
  static String get sendParcelCategoryMedium => _sendParcelCategoryMedium.tr;

  static const String _sendParcelCategoryLarge = 'send_parcel_category_large';
  static String get sendParcelCategoryLarge => _sendParcelCategoryLarge.tr;

  static const String _sendParcelCategoryFragile =
      'send_parcel_category_fragile';
  static String get sendParcelCategoryFragile => _sendParcelCategoryFragile.tr;

  static const String _sendParcelCategoryOther = 'send_parcel_category_other';
  static String get sendParcelCategoryOther => _sendParcelCategoryOther.tr;

  static const String _sendParcelEta = 'send_parcel_eta';

  /// `{minutes}` in the translation are replaced.
  static String sendParcelEta(String minutes) =>
      _sendParcelEta.tr.replaceFirst('{minutes}', minutes);

  static const String _parcelsMyC2cButton = 'parcels_my_c2c_button';
  static String get parcelsMyC2cButton => _parcelsMyC2cButton.tr;

  static const String _createParcelTitle = 'create_parcel_title';
  static String get createParcelTitle => _createParcelTitle.tr;

  static const String _createParcelSenderSection =
      'create_parcel_sender_section';
  static String get createParcelSenderSection => _createParcelSenderSection.tr;

  static const String _createParcelRecipientSection =
      'create_parcel_recipient_section';
  static String get createParcelRecipientSection =>
      _createParcelRecipientSection.tr;

  static const String _createParcelNameLabel = 'create_parcel_name_label';
  static String get createParcelNameLabel => _createParcelNameLabel.tr;

  static const String _createParcelPhoneLabel = 'create_parcel_phone_label';
  static String get createParcelPhoneLabel => _createParcelPhoneLabel.tr;

  static const String _createParcelAddressLabel = 'create_parcel_address_label';
  static String get createParcelAddressLabel => _createParcelAddressLabel.tr;

  static const String _createParcelAddressHint = 'create_parcel_address_hint';
  static String get createParcelAddressHint => _createParcelAddressHint.tr;

  static const String _createParcelBuildingLabel =
      'create_parcel_building_label';
  static String get createParcelBuildingLabel => _createParcelBuildingLabel.tr;

  static const String _createParcelFloorLabel = 'create_parcel_floor_label';
  static String get createParcelFloorLabel => _createParcelFloorLabel.tr;

  static const String _createParcelApartmentLabel =
      'create_parcel_apartment_label';
  static String get createParcelApartmentLabel =>
      _createParcelApartmentLabel.tr;

  static const String _createParcelNotesLabel = 'create_parcel_notes_label';
  static String get createParcelNotesLabel => _createParcelNotesLabel.tr;

  static const String _createParcelItemSection = 'create_parcel_item_section';
  static String get createParcelItemSection => _createParcelItemSection.tr;

  static const String _createParcelItemTitleLabel =
      'create_parcel_item_title_label';
  static String get createParcelItemTitleLabel =>
      _createParcelItemTitleLabel.tr;

  static const String _createParcelItemTitleHint =
      'create_parcel_item_title_hint';
  static String get createParcelItemTitleHint => _createParcelItemTitleHint.tr;

  static const String _createParcelDescriptionLabel =
      'create_parcel_description_label';
  static String get createParcelDescriptionLabel =>
      _createParcelDescriptionLabel.tr;

  static const String _createParcelDeclaredValueLabel =
      'create_parcel_declared_value_label';
  static String get createParcelDeclaredValueLabel =>
      _createParcelDeclaredValueLabel.tr;

  static const String _createParcelPickupInstructionsLabel =
      'create_parcel_pickup_instructions_label';
  static String get createParcelPickupInstructionsLabel =>
      _createParcelPickupInstructionsLabel.tr;

  static const String _createParcelDeliveryInstructionsLabel =
      'create_parcel_delivery_instructions_label';
  static String get createParcelDeliveryInstructionsLabel =>
      _createParcelDeliveryInstructionsLabel.tr;

  static const String _createParcelPaymentSection =
      'create_parcel_payment_section';
  static String get createParcelPaymentSection =>
      _createParcelPaymentSection.tr;

  static const String _createParcelPaymentSender =
      'create_parcel_payment_sender';
  static String get createParcelPaymentSender => _createParcelPaymentSender.tr;

  static const String _createParcelPaymentRecipient =
      'create_parcel_payment_recipient';
  static String get createParcelPaymentRecipient =>
      _createParcelPaymentRecipient.tr;

  static const String _createParcelPhotosSection =
      'create_parcel_photos_section';
  static String get createParcelPhotosSection => _createParcelPhotosSection.tr;

  static const String _createParcelPhotosHint = 'create_parcel_photos_hint';
  static String get createParcelPhotosHint => _createParcelPhotosHint.tr;

  static const String _createParcelTakePhoto = 'create_parcel_take_photo';
  static String get createParcelTakePhoto => _createParcelTakePhoto.tr;

  static const String _createParcelChoosePhotos = 'create_parcel_choose_photos';
  static String get createParcelChoosePhotos => _createParcelChoosePhotos.tr;

  static const String _createParcelPhotosRequired =
      'create_parcel_photos_required';
  static String get createParcelPhotosRequired =>
      _createParcelPhotosRequired.tr;

  static const String _createParcelPhotoTooLarge =
      'create_parcel_photo_too_large';
  static String get createParcelPhotoTooLarge => _createParcelPhotoTooLarge.tr;

  static const String _createParcelPhotoUnsupported =
      'create_parcel_photo_unsupported';
  static String get createParcelPhotoUnsupported =>
      _createParcelPhotoUnsupported.tr;

  static const String _createParcelAcknowledge = 'create_parcel_acknowledge';
  static String get createParcelAcknowledge => _createParcelAcknowledge.tr;

  static const String _createParcelAcknowledgeRequired =
      'create_parcel_acknowledge_required';
  static String get createParcelAcknowledgeRequired =>
      _createParcelAcknowledgeRequired.tr;

  static const String _createParcelSubmit = 'create_parcel_submit';
  static String get createParcelSubmit => _createParcelSubmit.tr;

  static const String _createParcelPriceChangedTitle =
      'create_parcel_price_changed_title';
  static String get createParcelPriceChangedTitle =>
      _createParcelPriceChangedTitle.tr;

  static const String _createParcelPriceChangedMessage =
      'create_parcel_price_changed_message';

  /// `{price}` in the translation are replaced.
  static String createParcelPriceChangedMessage(String price) =>
      _createParcelPriceChangedMessage.tr.replaceFirst('{price}', price);

  static const String _createParcelCreated = 'create_parcel_created';
  static String get createParcelCreated => _createParcelCreated.tr;

  static const String _createParcelTripSummary = 'create_parcel_trip_summary';

  /// `{km}`, `{category}`, `{weight}` in the translation are replaced.
  static String createParcelTripSummary(
    String km,
    String category,
    String weight,
  ) => _createParcelTripSummary.tr
      .replaceFirst('{km}', km)
      .replaceFirst('{category}', category)
      .replaceFirst('{weight}', weight);

  static const String _c2cErrorStaleVersion = 'c2c_error_stale_version';
  static String get c2cErrorStaleVersion => _c2cErrorStaleVersion.tr;

  static const String _c2cErrorRequestInProgress =
      'c2c_error_request_in_progress';
  static String get c2cErrorRequestInProgress => _c2cErrorRequestInProgress.tr;

  static const String _c2cErrorIdempotencyConflict =
      'c2c_error_idempotency_conflict';
  static String get c2cErrorIdempotencyConflict =>
      _c2cErrorIdempotencyConflict.tr;

  static const String _c2cErrorCancelAfterPickup =
      'c2c_error_cancel_after_pickup';
  static String get c2cErrorCancelAfterPickup => _c2cErrorCancelAfterPickup.tr;

  static const String _c2cErrorOtpNotAvailable = 'c2c_error_otp_not_available';
  static String get c2cErrorOtpNotAvailable => _c2cErrorOtpNotAvailable.tr;

  static const String _c2cParcelsTitle = 'c2c_parcels_title';
  static String get c2cParcelsTitle => _c2cParcelsTitle.tr;

  static const String _c2cParcelsTabSent = 'c2c_parcels_tab_sent';
  static String get c2cParcelsTabSent => _c2cParcelsTabSent.tr;

  static const String _c2cParcelsTabReceived = 'c2c_parcels_tab_received';
  static String get c2cParcelsTabReceived => _c2cParcelsTabReceived.tr;

  static const String _c2cParcelsEmptySent = 'c2c_parcels_empty_sent';
  static String get c2cParcelsEmptySent => _c2cParcelsEmptySent.tr;

  static const String _c2cParcelsEmptyReceived = 'c2c_parcels_empty_received';
  static String get c2cParcelsEmptyReceived => _c2cParcelsEmptyReceived.tr;

  static const String _c2cParcelTo = 'c2c_parcel_to';

  /// `{name}` in the translation are replaced.
  static String c2cParcelTo(String name) =>
      _c2cParcelTo.tr.replaceFirst('{name}', name);

  static const String _c2cParcelFrom = 'c2c_parcel_from';

  /// `{name}` in the translation are replaced.
  static String c2cParcelFrom(String name) =>
      _c2cParcelFrom.tr.replaceFirst('{name}', name);

  static const String _c2cStatusQuoted = 'c2c_status_quoted';
  static String get c2cStatusQuoted => _c2cStatusQuoted.tr;

  static const String _c2cStatusQuotedDesc = 'c2c_status_quoted_desc';
  static String get c2cStatusQuotedDesc => _c2cStatusQuotedDesc.tr;

  static const String _c2cStatusPendingPayment = 'c2c_status_pending_payment';
  static String get c2cStatusPendingPayment => _c2cStatusPendingPayment.tr;

  static const String _c2cStatusPendingPaymentDesc =
      'c2c_status_pending_payment_desc';
  static String get c2cStatusPendingPaymentDesc =>
      _c2cStatusPendingPaymentDesc.tr;

  static const String _c2cStatusPendingDispatch = 'c2c_status_pending_dispatch';
  static String get c2cStatusPendingDispatch => _c2cStatusPendingDispatch.tr;

  static const String _c2cStatusPendingDispatchDesc =
      'c2c_status_pending_dispatch_desc';
  static String get c2cStatusPendingDispatchDesc =>
      _c2cStatusPendingDispatchDesc.tr;

  static const String _c2cStatusDispatching = 'c2c_status_dispatching';
  static String get c2cStatusDispatching => _c2cStatusDispatching.tr;

  static const String _c2cStatusDispatchingDesc = 'c2c_status_dispatching_desc';
  static String get c2cStatusDispatchingDesc => _c2cStatusDispatchingDesc.tr;

  static const String _c2cStatusAssignmentFailed =
      'c2c_status_assignment_failed';
  static String get c2cStatusAssignmentFailed => _c2cStatusAssignmentFailed.tr;

  static const String _c2cStatusAssignmentFailedDesc =
      'c2c_status_assignment_failed_desc';
  static String get c2cStatusAssignmentFailedDesc =>
      _c2cStatusAssignmentFailedDesc.tr;

  static const String _c2cStatusDriverAssigned = 'c2c_status_driver_assigned';
  static String get c2cStatusDriverAssigned => _c2cStatusDriverAssigned.tr;

  static const String _c2cStatusDriverAssignedDesc =
      'c2c_status_driver_assigned_desc';
  static String get c2cStatusDriverAssignedDesc =>
      _c2cStatusDriverAssignedDesc.tr;

  static const String _c2cStatusDriverAccepted = 'c2c_status_driver_accepted';
  static String get c2cStatusDriverAccepted => _c2cStatusDriverAccepted.tr;

  static const String _c2cStatusDriverAcceptedDesc =
      'c2c_status_driver_accepted_desc';
  static String get c2cStatusDriverAcceptedDesc =>
      _c2cStatusDriverAcceptedDesc.tr;

  static const String _c2cStatusDriverAtPickup = 'c2c_status_driver_at_pickup';
  static String get c2cStatusDriverAtPickup => _c2cStatusDriverAtPickup.tr;

  static const String _c2cStatusDriverAtPickupDesc =
      'c2c_status_driver_at_pickup_desc';
  static String get c2cStatusDriverAtPickupDesc =>
      _c2cStatusDriverAtPickupDesc.tr;

  static const String _c2cStatusPickedUp = 'c2c_status_picked_up';
  static String get c2cStatusPickedUp => _c2cStatusPickedUp.tr;

  static const String _c2cStatusPickedUpDesc = 'c2c_status_picked_up_desc';
  static String get c2cStatusPickedUpDesc => _c2cStatusPickedUpDesc.tr;

  static const String _c2cStatusOutForDelivery = 'c2c_status_out_for_delivery';
  static String get c2cStatusOutForDelivery => _c2cStatusOutForDelivery.tr;

  static const String _c2cStatusOutForDeliveryDesc =
      'c2c_status_out_for_delivery_desc';
  static String get c2cStatusOutForDeliveryDesc =>
      _c2cStatusOutForDeliveryDesc.tr;

  static const String _c2cStatusDelivered = 'c2c_status_delivered';
  static String get c2cStatusDelivered => _c2cStatusDelivered.tr;

  static const String _c2cStatusDeliveredDesc = 'c2c_status_delivered_desc';
  static String get c2cStatusDeliveredDesc => _c2cStatusDeliveredDesc.tr;

  static const String _c2cStatusFailedDelivery = 'c2c_status_failed_delivery';
  static String get c2cStatusFailedDelivery => _c2cStatusFailedDelivery.tr;

  static const String _c2cStatusFailedDeliveryDesc =
      'c2c_status_failed_delivery_desc';
  static String get c2cStatusFailedDeliveryDesc =>
      _c2cStatusFailedDeliveryDesc.tr;

  static const String _c2cStatusReturningToSender =
      'c2c_status_returning_to_sender';
  static String get c2cStatusReturningToSender =>
      _c2cStatusReturningToSender.tr;

  static const String _c2cStatusReturningToSenderDesc =
      'c2c_status_returning_to_sender_desc';
  static String get c2cStatusReturningToSenderDesc =>
      _c2cStatusReturningToSenderDesc.tr;

  static const String _c2cStatusReturnedToSender =
      'c2c_status_returned_to_sender';
  static String get c2cStatusReturnedToSender => _c2cStatusReturnedToSender.tr;

  static const String _c2cStatusReturnedToSenderDesc =
      'c2c_status_returned_to_sender_desc';
  static String get c2cStatusReturnedToSenderDesc =>
      _c2cStatusReturnedToSenderDesc.tr;

  static const String _c2cStatusCancelled = 'c2c_status_cancelled';
  static String get c2cStatusCancelled => _c2cStatusCancelled.tr;

  static const String _c2cStatusCancelledDesc = 'c2c_status_cancelled_desc';
  static String get c2cStatusCancelledDesc => _c2cStatusCancelledDesc.tr;

  static const String _c2cStatusUnknown = 'c2c_status_unknown';
  static String get c2cStatusUnknown => _c2cStatusUnknown.tr;

  static const String _c2cStatusUnknownDesc = 'c2c_status_unknown_desc';
  static String get c2cStatusUnknownDesc => _c2cStatusUnknownDesc.tr;

  static const String _c2cTrackingTitle = 'c2c_tracking_title';
  static String get c2cTrackingTitle => _c2cTrackingTitle.tr;

  static const String _c2cTrackingEta = 'c2c_tracking_eta';

  /// `{minutes}` in the translation are replaced.
  static String c2cTrackingEta(String minutes) =>
      _c2cTrackingEta.tr.replaceFirst('{minutes}', minutes);

  static const String _c2cTrackingRoleSender = 'c2c_tracking_role_sender';
  static String get c2cTrackingRoleSender => _c2cTrackingRoleSender.tr;

  static const String _c2cTrackingRoleRecipient = 'c2c_tracking_role_recipient';
  static String get c2cTrackingRoleRecipient => _c2cTrackingRoleRecipient.tr;

  static const String _c2cTrackingDriver = 'c2c_tracking_driver';
  static String get c2cTrackingDriver => _c2cTrackingDriver.tr;

  static const String _c2cTrackingDriverLive = 'c2c_tracking_driver_live';
  static String get c2cTrackingDriverLive => _c2cTrackingDriverLive.tr;

  static const String _c2cTrackingCancelButton = 'c2c_tracking_cancel_button';
  static String get c2cTrackingCancelButton => _c2cTrackingCancelButton.tr;

  static const String _c2cTrackingRetryButton = 'c2c_tracking_retry_button';
  static String get c2cTrackingRetryButton => _c2cTrackingRetryButton.tr;

  static const String _c2cTrackingOtpButton = 'c2c_tracking_otp_button';
  static String get c2cTrackingOtpButton => _c2cTrackingOtpButton.tr;

  static const String _c2cTrackingReturnOtpButton =
      'c2c_tracking_return_otp_button';
  static String get c2cTrackingReturnOtpButton =>
      _c2cTrackingReturnOtpButton.tr;

  static const String _c2cTrackingSupportButton = 'c2c_tracking_support_button';
  static String get c2cTrackingSupportButton => _c2cTrackingSupportButton.tr;

  static const String _c2cTrackingOtpTitle = 'c2c_tracking_otp_title';
  static String get c2cTrackingOtpTitle => _c2cTrackingOtpTitle.tr;

  static const String _c2cTrackingReturnOtpTitle =
      'c2c_tracking_return_otp_title';
  static String get c2cTrackingReturnOtpTitle => _c2cTrackingReturnOtpTitle.tr;

  static const String _c2cTrackingOtpHintDelivery =
      'c2c_tracking_otp_hint_delivery';
  static String get c2cTrackingOtpHintDelivery =>
      _c2cTrackingOtpHintDelivery.tr;

  static const String _c2cTrackingOtpHintReturn =
      'c2c_tracking_otp_hint_return';
  static String get c2cTrackingOtpHintReturn => _c2cTrackingOtpHintReturn.tr;

  static const String _c2cTrackingOtpExpires = 'c2c_tracking_otp_expires';

  /// `{time}` in the translation are replaced.
  static String c2cTrackingOtpExpires(String time) =>
      _c2cTrackingOtpExpires.tr.replaceFirst('{time}', time);

  static const String _c2cTrackingOtpNew = 'c2c_tracking_otp_new';
  static String get c2cTrackingOtpNew => _c2cTrackingOtpNew.tr;

  static const String _c2cTrackingCancelTitle = 'c2c_tracking_cancel_title';
  static String get c2cTrackingCancelTitle => _c2cTrackingCancelTitle.tr;

  static const String _c2cTrackingReasonLabel = 'c2c_tracking_reason_label';
  static String get c2cTrackingReasonLabel => _c2cTrackingReasonLabel.tr;

  static const String _c2cTrackingNoteHint = 'c2c_tracking_note_hint';
  static String get c2cTrackingNoteHint => _c2cTrackingNoteHint.tr;

  static const String _c2cTrackingCancelConfirm = 'c2c_tracking_cancel_confirm';
  static String get c2cTrackingCancelConfirm => _c2cTrackingCancelConfirm.tr;

  static const String _c2cTrackingCancelled = 'c2c_tracking_cancelled';
  static String get c2cTrackingCancelled => _c2cTrackingCancelled.tr;

  static const String _c2cTrackingRetried = 'c2c_tracking_retried';
  static String get c2cTrackingRetried => _c2cTrackingRetried.tr;

  static const String _c2cTrackingSupportTitle = 'c2c_tracking_support_title';
  static String get c2cTrackingSupportTitle => _c2cTrackingSupportTitle.tr;

  static const String _c2cTrackingSupportDescription =
      'c2c_tracking_support_description';
  static String get c2cTrackingSupportDescription =>
      _c2cTrackingSupportDescription.tr;

  static const String _c2cTrackingSupportTooShort =
      'c2c_tracking_support_too_short';
  static String get c2cTrackingSupportTooShort =>
      _c2cTrackingSupportTooShort.tr;

  static const String _c2cTrackingSupportSend = 'c2c_tracking_support_send';
  static String get c2cTrackingSupportSend => _c2cTrackingSupportSend.tr;

  static const String _c2cTrackingSupportSent = 'c2c_tracking_support_sent';
  static String get c2cTrackingSupportSent => _c2cTrackingSupportSent.tr;

  static const String _c2cTrackingDetailsTitle = 'c2c_tracking_details_title';
  static String get c2cTrackingDetailsTitle => _c2cTrackingDetailsTitle.tr;

  static const String _c2cTrackingSender = 'c2c_tracking_sender';
  static String get c2cTrackingSender => _c2cTrackingSender.tr;

  static const String _c2cTrackingRecipient = 'c2c_tracking_recipient';
  static String get c2cTrackingRecipient => _c2cTrackingRecipient.tr;

  static const String _c2cTrackingDescription = 'c2c_tracking_description';
  static String get c2cTrackingDescription => _c2cTrackingDescription.tr;

  static const String _c2cTrackingDeclaredValue = 'c2c_tracking_declared_value';
  static String get c2cTrackingDeclaredValue => _c2cTrackingDeclaredValue.tr;

  static const String _c2cTrackingPickupInstructions =
      'c2c_tracking_pickup_instructions';
  static String get c2cTrackingPickupInstructions =>
      _c2cTrackingPickupInstructions.tr;

  static const String _c2cTrackingDeliveryInstructions =
      'c2c_tracking_delivery_instructions';
  static String get c2cTrackingDeliveryInstructions =>
      _c2cTrackingDeliveryInstructions.tr;

  static const String _c2cTrackingWeight = 'c2c_tracking_weight';

  /// `{kg}` in the translation are replaced.
  static String c2cTrackingWeight(String kg) =>
      _c2cTrackingWeight.tr.replaceFirst('{kg}', kg);

  static const String _c2cTrackingPhotos = 'c2c_tracking_photos';

  /// `{count}` in the translation are replaced.
  static String c2cTrackingPhotos(String count) =>
      _c2cTrackingPhotos.tr.replaceFirst('{count}', count);

  static const String _c2cTrackingPayment = 'c2c_tracking_payment';
  static String get c2cTrackingPayment => _c2cTrackingPayment.tr;

  static const String _c2cTrackingTotal = 'c2c_tracking_total';
  static String get c2cTrackingTotal => _c2cTrackingTotal.tr;

  static const String _c2cTrackingTimelineTitle = 'c2c_tracking_timeline_title';
  static String get c2cTrackingTimelineTitle => _c2cTrackingTimelineTitle.tr;

  static const String _c2cTrackingPickupMarker = 'c2c_tracking_pickup_marker';
  static String get c2cTrackingPickupMarker => _c2cTrackingPickupMarker.tr;

  static const String _c2cTrackingDropoffMarker = 'c2c_tracking_dropoff_marker';
  static String get c2cTrackingDropoffMarker => _c2cTrackingDropoffMarker.tr;

  static const String _c2cCancelReasonSenderCancelled =
      'c2c_cancel_reason_sender_cancelled';
  static String get c2cCancelReasonSenderCancelled =>
      _c2cCancelReasonSenderCancelled.tr;

  static const String _c2cCancelReasonWrongAddress =
      'c2c_cancel_reason_wrong_address';
  static String get c2cCancelReasonWrongAddress =>
      _c2cCancelReasonWrongAddress.tr;

  static const String _c2cCancelReasonOther = 'c2c_cancel_reason_other';
  static String get c2cCancelReasonOther => _c2cCancelReasonOther.tr;

  static const String _c2cSupportReasonSenderUnreachable =
      'c2c_support_reason_sender_unreachable';
  static String get c2cSupportReasonSenderUnreachable =>
      _c2cSupportReasonSenderUnreachable.tr;

  static const String _c2cSupportReasonRecipientUnreachable =
      'c2c_support_reason_recipient_unreachable';
  static String get c2cSupportReasonRecipientUnreachable =>
      _c2cSupportReasonRecipientUnreachable.tr;

  static const String _c2cSupportReasonWrongAddress =
      'c2c_support_reason_wrong_address';
  static String get c2cSupportReasonWrongAddress =>
      _c2cSupportReasonWrongAddress.tr;

  static const String _c2cSupportReasonParcelDamaged =
      'c2c_support_reason_parcel_damaged';
  static String get c2cSupportReasonParcelDamaged =>
      _c2cSupportReasonParcelDamaged.tr;

  static const String _c2cSupportReasonOther = 'c2c_support_reason_other';
  static String get c2cSupportReasonOther => _c2cSupportReasonOther.tr;

  static const String _c2cHeroBadge = 'c2c_hero_badge';
  static String get c2cHeroBadge => _c2cHeroBadge.tr;

  static const String _c2cHeroTitle = 'c2c_hero_title';
  static String get c2cHeroTitle => _c2cHeroTitle.tr;

  static const String _c2cHeroSubtitle = 'c2c_hero_subtitle';
  static String get c2cHeroSubtitle => _c2cHeroSubtitle.tr;

  static const String _c2cHeroButton = 'c2c_hero_button';
  static String get c2cHeroButton => _c2cHeroButton.tr;

  static const String _c2cHeroMyParcels = 'c2c_hero_my_parcels';
  static String get c2cHeroMyParcels => _c2cHeroMyParcels.tr;

  // --- Restaurants ---
  static const String _restaurantsTitle = 'restaurants_title';
  static String get restaurantsTitle => _restaurantsTitle.tr;

  static const String _restaurantsSubtitle = 'restaurants_subtitle';
  static String restaurantsSubtitle(int count) =>
      _restaurantsSubtitle.tr.replaceFirst('{count}', '$count');

  static const String _restaurantsFilterNearest = 'restaurants_filter_nearest';
  static String get restaurantsFilterNearest => _restaurantsFilterNearest.tr;

  static const String _restaurantsFilterTopRated =
      'restaurants_filter_top_rated';
  static String get restaurantsFilterTopRated => _restaurantsFilterTopRated.tr;

  static const String _restaurantsFilterFastest = 'restaurants_filter_fastest';
  static String get restaurantsFilterFastest => _restaurantsFilterFastest.tr;

  static const String _restaurantsSectionTitle = 'restaurants_section_title';
  static String get restaurantsSectionTitle => _restaurantsSectionTitle.tr;

  static const String _restaurantsNoSearchResults =
      'restaurants_no_search_results';
  static String get restaurantsNoSearchResults =>
      _restaurantsNoSearchResults.tr;

  static const String _categoryStoresEmpty = 'category_stores_empty';
  static String get categoryStoresEmpty => _categoryStoresEmpty.tr;

  // --- Store (card & details) ---
  static const String _storeFreeDelivery = 'store_free_delivery';
  static String get storeFreeDelivery => _storeFreeDelivery.tr;

  static const String _storeDeliveryFrom = 'store_delivery_from';

  /// [amount] already carries its currency, e.g. `7 SAR`.
  static String storeDeliveryFrom(String amount) =>
      _storeDeliveryFrom.tr.replaceFirst('{amount}', amount);

  static const String _storeDeliveryMinutes = 'store_delivery_minutes';

  /// `{count}` in the translation is replaced with the minutes.
  static String storeDeliveryMinutes(int count) =>
      _storeDeliveryMinutes.tr.replaceFirst('{count}', '$count');

  static const String _storeClosedBadge = 'store_closed_badge';
  static String get storeClosedBadge => _storeClosedBadge.tr;

  /// In place of a rating, for a store nobody has rated yet.
  static const String _storeNewBadge = 'store_new_badge';
  static String get storeNewBadge => _storeNewBadge.tr;

  static const String _storeDetailsOpenNowBadge =
      'store_details_open_now_badge';
  static String get storeDetailsOpenNowBadge => _storeDetailsOpenNowBadge.tr;

  static const String _storeDetailsSectionTitle = 'store_details_section_title';
  static String get storeDetailsSectionTitle => _storeDetailsSectionTitle.tr;

  static const String _storeDetailsNoItems = 'store_details_no_items';
  static String get storeDetailsNoItems => _storeDetailsNoItems.tr;

  static const String _storeDetailsCartViewButton =
      'store_details_cart_view_button';
  static String get storeDetailsCartViewButton =>
      _storeDetailsCartViewButton.tr;

  static const String _storeDetailsCartCount = 'store_details_cart_count';

  /// `{count}` in the translation is replaced with the live cart total.
  static String storeDetailsCartCount(int count) =>
      _storeDetailsCartCount.tr.replaceFirst('{count}', '$count');

  // --- Catalog lists ---
  /// Tap-to-retry row at the end of a paginated list.
  static const String _loadMoreFailed = 'load_more_failed';
  static String get loadMoreFailed => _loadMoreFailed.tr;

  /// The backend has no delivery zone to browse.
  static const String _zoneUnavailable = 'zone_unavailable';
  static String get zoneUnavailable => _zoneUnavailable.tr;

  /// The camera or gallery refused to open — usually access denied.
  static const String _mediaPickerFailed = 'media_picker_failed';
  static String get mediaPickerFailed => _mediaPickerFailed.tr;

  // --- Cart ---
  static const String _cartTitle = 'cart_title';
  static String get cartTitle => _cartTitle.tr;

  static const String _cartEmptyMessage = 'cart_empty_message';
  static String get cartEmptyMessage => _cartEmptyMessage.tr;

  static const String _cartProductsValueLabel = 'cart_products_value_label';
  static String get cartProductsValueLabel => _cartProductsValueLabel.tr;

  static const String _cartTotalLabel = 'cart_total_label';
  static String get cartTotalLabel => _cartTotalLabel.tr;

  static const String _cartContinueButton = 'cart_continue_button';
  static String get cartContinueButton => _cartContinueButton.tr;

  static const String _cartRemoveItem = 'cart_remove_item';
  static String get cartRemoveItem => _cartRemoveItem.tr;

  /// The cart endpoints quote no delivery fee — it depends on the address.
  static const String _cartDeliveryFeeAtCheckout =
      'cart_delivery_fee_at_checkout';
  static String get cartDeliveryFeeAtCheckout => _cartDeliveryFeeAtCheckout.tr;

  static const String _cartTotalBeforeDelivery = 'cart_total_before_delivery';
  static String get cartTotalBeforeDelivery => _cartTotalBeforeDelivery.tr;

  static const String _cartLineGone = 'cart_line_gone';
  static String get cartLineGone => _cartLineGone.tr;

  static const String _cartOtherStoreTitle = 'cart_other_store_title';
  static String get cartOtherStoreTitle => _cartOtherStoreTitle.tr;

  static const String _cartOtherStoreBody = 'cart_other_store_body';
  static String get cartOtherStoreBody => _cartOtherStoreBody.tr;

  static const String _cartOtherStoreConfirm = 'cart_other_store_confirm';
  static String get cartOtherStoreConfirm => _cartOtherStoreConfirm.tr;

  // --- Order confirmation ---
  static const String _orderConfirmationTitle = 'order_confirmation_title';
  static String get orderConfirmationTitle => _orderConfirmationTitle.tr;

  static const String _orderConfirmationAddressSectionTitle =
      'order_confirmation_address_section_title';
  static String get orderConfirmationAddressSectionTitle =>
      _orderConfirmationAddressSectionTitle.tr;

  static const String _orderConfirmationChangeButton =
      'order_confirmation_change_button';
  static String get orderConfirmationChangeButton =>
      _orderConfirmationChangeButton.tr;

  static const String _orderConfirmationPaymentSectionTitle =
      'order_confirmation_payment_section_title';
  static String get orderConfirmationPaymentSectionTitle =>
      _orderConfirmationPaymentSectionTitle.tr;

  static const String _orderConfirmationPaymentTitle =
      'order_confirmation_payment_title';
  static String get orderConfirmationPaymentTitle =>
      _orderConfirmationPaymentTitle.tr;

  static const String _orderConfirmationPaymentDescription =
      'order_confirmation_payment_description';
  static String get orderConfirmationPaymentDescription =>
      _orderConfirmationPaymentDescription.tr;

  static const String _orderConfirmationSummarySectionTitle =
      'order_confirmation_summary_section_title';
  static String get orderConfirmationSummarySectionTitle =>
      _orderConfirmationSummarySectionTitle.tr;

  static const String _orderConfirmationDeliveryFeeLabel =
      'order_confirmation_delivery_fee_label';
  static String get orderConfirmationDeliveryFeeLabel =>
      _orderConfirmationDeliveryFeeLabel.tr;

  static const String _orderConfirmationConfirmButton =
      'order_confirmation_confirm_button';
  static String get orderConfirmationConfirmButton =>
      _orderConfirmationConfirmButton.tr;

  // --- Order tracking ---
  static const String _orderTrackingTitle = 'order_tracking_title';
  static String get orderTrackingTitle => _orderTrackingTitle.tr;

  static const String _orderTrackingCurrentStatusLabel =
      'order_tracking_current_status_label';
  static String get orderTrackingCurrentStatusLabel =>
      _orderTrackingCurrentStatusLabel.tr;

  static const String _orderTrackingStatusDescription =
      'order_tracking_status_description';
  static String get orderTrackingStatusDescription =>
      _orderTrackingStatusDescription.tr;

  static const String _orderTrackingOrderNumberLabel =
      'order_tracking_order_number_label';
  static String get orderTrackingOrderNumberLabel =>
      _orderTrackingOrderNumberLabel.tr;

  static const String _orderTrackingCallButton = 'order_tracking_call_button';
  static String get orderTrackingCallButton => _orderTrackingCallButton.tr;

  static const String _orderTrackingStepSentTitle =
      'order_tracking_step_sent_title';
  static String get orderTrackingStepSentTitle =>
      _orderTrackingStepSentTitle.tr;

  static const String _orderTrackingStepSentSubtitle =
      'order_tracking_step_sent_subtitle';
  static String get orderTrackingStepSentSubtitle =>
      _orderTrackingStepSentSubtitle.tr;

  static const String _orderTrackingStepPreparingTitle =
      'order_tracking_step_preparing_title';
  static String get orderTrackingStepPreparingTitle =>
      _orderTrackingStepPreparingTitle.tr;

  static const String _orderTrackingStepPreparingSubtitle =
      'order_tracking_step_preparing_subtitle';

  /// `{store}` in the translation is replaced with the store's name.
  static String orderTrackingStepPreparingSubtitle(String storeName) =>
      _orderTrackingStepPreparingSubtitle.tr.replaceFirst('{store}', storeName);

  static const String _orderTrackingStepCourierToStoreTitle =
      'order_tracking_step_courier_to_store_title';
  static String get orderTrackingStepCourierToStoreTitle =>
      _orderTrackingStepCourierToStoreTitle.tr;

  static const String _orderTrackingStepCourierToStoreSubtitle =
      'order_tracking_step_courier_to_store_subtitle';
  static String get orderTrackingStepCourierToStoreSubtitle =>
      _orderTrackingStepCourierToStoreSubtitle.tr;

  static const String _orderTrackingStepCourierToYouTitle =
      'order_tracking_step_courier_to_you_title';
  static String get orderTrackingStepCourierToYouTitle =>
      _orderTrackingStepCourierToYouTitle.tr;

  static const String _orderTrackingStepCourierToYouSubtitle =
      'order_tracking_step_courier_to_you_subtitle';
  static String get orderTrackingStepCourierToYouSubtitle =>
      _orderTrackingStepCourierToYouSubtitle.tr;

  static const String _orderTrackingStepDeliveredTitle =
      'order_tracking_step_delivered_title';
  static String get orderTrackingStepDeliveredTitle =>
      _orderTrackingStepDeliveredTitle.tr;

  static const String _orderTrackingStepDeliveredSubtitle =
      'order_tracking_step_delivered_subtitle';
  static String get orderTrackingStepDeliveredSubtitle =>
      _orderTrackingStepDeliveredSubtitle.tr;

  static const String _checkoutAddAddress = 'checkout_add_address';
  static String get checkoutAddAddress => _checkoutAddAddress.tr;

  static const String _checkoutNoAddresses = 'checkout_no_addresses';
  static String get checkoutNoAddresses => _checkoutNoAddresses.tr;

  static const String _checkoutEmptyCart = 'checkout_empty_cart';
  static String get checkoutEmptyCart => _checkoutEmptyCart.tr;

  static const String _checkoutUnknownStore = 'checkout_unknown_store';
  static String get checkoutUnknownStore => _checkoutUnknownStore.tr;

  static const String _checkoutNoAddress = 'checkout_no_address';
  static String get checkoutNoAddress => _checkoutNoAddress.tr;

  static const String _checkoutAddressWithoutLocation =
      'checkout_address_without_location';
  static String get checkoutAddressWithoutLocation =>
      _checkoutAddressWithoutLocation.tr;

  static const String _checkoutOutOfCoverage = 'checkout_out_of_coverage';
  static String get checkoutOutOfCoverage => _checkoutOutOfCoverage.tr;

  static const String _checkoutCodLimit = 'checkout_cod_limit';
  static String get checkoutCodLimit => _checkoutCodLimit.tr;

  /// The store has no map pin, so delivery can't be quoted.
  static const String _checkoutStoreWithoutLocation =
      'checkout_store_without_location';
  static String get checkoutStoreWithoutLocation =>
      _checkoutStoreWithoutLocation.tr;

  static const String _checkoutQuoteLoading = 'checkout_quote_loading';
  static String get checkoutQuoteLoading => _checkoutQuoteLoading.tr;

  static const String _checkoutTaxLabel = 'checkout_tax_label';
  static String get checkoutTaxLabel => _checkoutTaxLabel.tr;

  static const String _checkoutCouponDiscountLabel =
      'checkout_coupon_discount_label';
  static String get checkoutCouponDiscountLabel =>
      _checkoutCouponDiscountLabel.tr;

  static const String _checkoutFreeDelivery = 'checkout_free_delivery';
  static String get checkoutFreeDelivery => _checkoutFreeDelivery.tr;

  static const String _checkoutFreeDeliveryCoupon =
      'checkout_free_delivery_coupon';
  static String get checkoutFreeDeliveryCoupon =>
      _checkoutFreeDeliveryCoupon.tr;

  static const String _checkoutFreeDeliverySubscription =
      'checkout_free_delivery_subscription';
  static String get checkoutFreeDeliverySubscription =>
      _checkoutFreeDeliverySubscription.tr;

  static const String _checkoutFreeDeliveryLoyalty =
      'checkout_free_delivery_loyalty';
  static String get checkoutFreeDeliveryLoyalty =>
      _checkoutFreeDeliveryLoyalty.tr;

  /// 409 `order_in_progress` — the first attempt is still being processed.
  static const String _checkoutOrderInProgress = 'checkout_order_in_progress';
  static String get checkoutOrderInProgress => _checkoutOrderInProgress.tr;

  /// 409 `idempotency_conflict`.
  static const String _checkoutOrderChanged = 'checkout_order_changed';
  static String get checkoutOrderChanged => _checkoutOrderChanged.tr;

  static const String _checkoutOrderPlaced = 'checkout_order_placed';
  static String get checkoutOrderPlaced => _checkoutOrderPlaced.tr;

  static const String _checkoutOrderPlacedTotal = 'checkout_order_placed_total';

  /// `{total}` is replaced with the confirmed total, currency included.
  static String checkoutOrderPlacedTotal(String total) =>
      _checkoutOrderPlacedTotal.tr.replaceFirst('{total}', total);

  static const String _orderTrackingRejectedTitle =
      'order_tracking_rejected_title';
  static String get orderTrackingRejectedTitle =>
      _orderTrackingRejectedTitle.tr;

  static const String _orderTrackingCancelledTitle =
      'order_tracking_cancelled_title';
  static String get orderTrackingCancelledTitle =>
      _orderTrackingCancelledTitle.tr;

  static const String _orderTrackingAssignmentFailedTitle =
      'order_tracking_assignment_failed_title';
  static String get orderTrackingAssignmentFailedTitle =>
      _orderTrackingAssignmentFailedTitle.tr;

  static const String _orderTrackingFailedDescription =
      'order_tracking_failed_description';
  static String get orderTrackingFailedDescription =>
      _orderTrackingFailedDescription.tr;

  static const String _orderTrackingAssignmentFailedDescription =
      'order_tracking_assignment_failed_description';
  static String get orderTrackingAssignmentFailedDescription =>
      _orderTrackingAssignmentFailedDescription.tr;

  static const String _orderTrackingBrowseStores =
      'order_tracking_browse_stores';
  static String get orderTrackingBrowseStores => _orderTrackingBrowseStores.tr;

  static const String _orderTrackingStale = 'order_tracking_stale';
  static String get orderTrackingStale => _orderTrackingStale.tr;

  static const String _orderTrackingOtpTitle = 'order_tracking_otp_title';
  static String get orderTrackingOtpTitle => _orderTrackingOtpTitle.tr;

  static const String _orderTrackingOtpHint = 'order_tracking_otp_hint';
  static String get orderTrackingOtpHint => _orderTrackingOtpHint.tr;

  static const String _orderTrackingOtpExpires = 'order_tracking_otp_expires';

  /// `{time}` is replaced with [time].
  static String orderTrackingOtpExpires(String time) =>
      _orderTrackingOtpExpires.tr.replaceFirst('{time}', time);

  static const String _orderTrackingOtpUnavailable =
      'order_tracking_otp_unavailable';
  static String get orderTrackingOtpUnavailable =>
      _orderTrackingOtpUnavailable.tr;

  static const String _orderTrackingOtpFailed = 'order_tracking_otp_failed';
  static String get orderTrackingOtpFailed => _orderTrackingOtpFailed.tr;

  static const String _orderTrackingOtpRetry = 'order_tracking_otp_retry';
  static String get orderTrackingOtpRetry => _orderTrackingOtpRetry.tr;

  static const String _orderTrackingOtpNewCode = 'order_tracking_otp_new_code';
  static String get orderTrackingOtpNewCode => _orderTrackingOtpNewCode.tr;

  static const String _orderTrackingItemsTitle = 'order_tracking_items_title';
  static String get orderTrackingItemsTitle => _orderTrackingItemsTitle.tr;

  static const String _orderTrackingCourierLabel =
      'order_tracking_courier_label';
  static String get orderTrackingCourierLabel => _orderTrackingCourierLabel.tr;

  static const String _orderTrackingStoreLabel = 'order_tracking_store_label';
  static String get orderTrackingStoreLabel => _orderTrackingStoreLabel.tr;

  static const String _orderTrackingLocationLive =
      'order_tracking_location_live';
  static String get orderTrackingLocationLive => _orderTrackingLocationLive.tr;

  static const String _orderTrackingLocationUnavailable =
      'order_tracking_location_unavailable';
  static String get orderTrackingLocationUnavailable =>
      _orderTrackingLocationUnavailable.tr;

  // --- Cancel order ---
  static const String _orderCancelButton = 'order_cancel_button';
  static String get orderCancelButton => _orderCancelButton.tr;

  static const String _orderCancelSheetTitle = 'order_cancel_sheet_title';
  static String get orderCancelSheetTitle => _orderCancelSheetTitle.tr;

  static const String _orderCancelSheetSubtitle = 'order_cancel_sheet_subtitle';
  static String get orderCancelSheetSubtitle => _orderCancelSheetSubtitle.tr;

  static const String _orderCancelReasonLabel = 'order_cancel_reason_label';
  static String get orderCancelReasonLabel => _orderCancelReasonLabel.tr;

  static const String _orderCancelReasonHint = 'order_cancel_reason_hint';
  static String get orderCancelReasonHint => _orderCancelReasonHint.tr;

  static const String _orderCancelKeep = 'order_cancel_keep';
  static String get orderCancelKeep => _orderCancelKeep.tr;

  static const String _orderCancelled = 'order_cancelled';
  static String get orderCancelled => _orderCancelled.tr;

  /// 403 — the merchant accepted the order before the cancel arrived.
  static const String _orderCancelNotAllowed = 'order_cancel_not_allowed';
  static String get orderCancelNotAllowed => _orderCancelNotAllowed.tr;

  // --- Subscriptions ---
  static const String _subscriptionsTitle = 'subscriptions_title';
  static String get subscriptionsTitle => _subscriptionsTitle.tr;

  static const String _subscriptionsSubtitle = 'subscriptions_subtitle';
  static String get subscriptionsSubtitle => _subscriptionsSubtitle.tr;

  static const String _subscriptionsAreaSelectorTitle =
      'subscriptions_area_selector_title';
  static String get subscriptionsAreaSelectorTitle =>
      _subscriptionsAreaSelectorTitle.tr;

  static const String _subscriptionsNoZones = 'subscriptions_no_zones';
  static String get subscriptionsNoZones => _subscriptionsNoZones.tr;

  static const String _subscriptionsNoPlans = 'subscriptions_no_plans';
  static String get subscriptionsNoPlans => _subscriptionsNoPlans.tr;

  static const String _subscriptionsPlanSummary = 'subscriptions_plan_summary';

  /// `{deliveries}` and `{days}` in the translation are replaced with the
  /// plan's delivery count and validity.
  static String subscriptionsPlanSummary(int deliveries, int days) =>
      _subscriptionsPlanSummary.tr
          .replaceFirst('{deliveries}', '$deliveries')
          .replaceFirst('{days}', '$days');

  static const String _subscriptionsBestValueBadge =
      'subscriptions_best_value_badge';
  static String get subscriptionsBestValueBadge =>
      _subscriptionsBestValueBadge.tr;

  static const String _subscriptionsConfirmTitle =
      'subscriptions_confirm_title';

  /// `{plan}` in the translation is replaced with the plan name.
  static String subscriptionsConfirmTitle(String plan) =>
      _subscriptionsConfirmTitle.tr.replaceFirst('{plan}', plan);

  static const String _subscriptionsConfirmMessage =
      'subscriptions_confirm_message';

  /// `{deliveries}`, `{price}` and `{currency}` in the translation are
  /// replaced with the plan's values.
  static String subscriptionsConfirmMessage(
    int deliveries,
    String price,
    String currency,
  ) => _subscriptionsConfirmMessage.tr
      .replaceFirst('{deliveries}', '$deliveries')
      .replaceFirst('{price}', price)
      .replaceFirst('{currency}', currency);

  static const String _subscriptionsSubscribeButton =
      'subscriptions_subscribe_button';
  static String get subscriptionsSubscribeButton =>
      _subscriptionsSubscribeButton.tr;

  /// HTTP 201 from purchase-intent: created, unpaid, awaiting an admin.
  static const String _subscriptionsPendingApproval =
      'subscriptions_pending_approval';
  static String get subscriptionsPendingApproval =>
      _subscriptionsPendingApproval.tr;

  static const String _subscriptionsActiveTitle = 'subscriptions_active_title';
  static String get subscriptionsActiveTitle => _subscriptionsActiveTitle.tr;

  static const String _subscriptionsActiveRemaining =
      'subscriptions_active_remaining';

  /// `{remaining}` and `{total}` in the translation are replaced with the
  /// active subscription's delivery counts.
  static String subscriptionsActiveRemaining(int remaining, int total) =>
      _subscriptionsActiveRemaining.tr
          .replaceFirst('{remaining}', '$remaining')
          .replaceFirst('{total}', '$total');

  static const String _subscriptionsActiveExpires =
      'subscriptions_active_expires';

  /// `{date}` in the translation is replaced with the formatted expiry date.
  static String subscriptionsActiveExpires(String date) =>
      _subscriptionsActiveExpires.tr.replaceFirst('{date}', date);

  static const String _subscriptionsFooterNote = 'subscriptions_footer_note';
  static String get subscriptionsFooterNote => _subscriptionsFooterNote.tr;

  static const String _subscriptionsProductDelivery =
      'subscriptions_product_delivery';
  static String get subscriptionsProductDelivery =>
      _subscriptionsProductDelivery.tr;

  static const String _subscriptionsProductParcels =
      'subscriptions_product_parcels';
  static String get subscriptionsProductParcels =>
      _subscriptionsProductParcels.tr;

  static const String _subscriptionsPlanMaxDistance =
      'subscriptions_plan_max_distance';

  /// `{km}` in the translation is replaced with the plan's distance limit.
  static String subscriptionsPlanMaxDistance(String km) =>
      _subscriptionsPlanMaxDistance.tr.replaceFirst('{km}', km);

  static const String _subscriptionsPlanMaxWeight =
      'subscriptions_plan_max_weight';

  /// `{kg}` in the translation is replaced with the plan's weight limit.
  static String subscriptionsPlanMaxWeight(String kg) =>
      _subscriptionsPlanMaxWeight.tr.replaceFirst('{kg}', kg);

  static const String _subscriptionsNoParcelPlans =
      'subscriptions_no_parcel_plans';
  static String get subscriptionsNoParcelPlans =>
      _subscriptionsNoParcelPlans.tr;

  /// Parcel plans have no purchase endpoint — an admin grants them.
  static const String _subscriptionsParcelPlanInfo =
      'subscriptions_parcel_plan_info';
  static String get subscriptionsParcelPlanInfo =>
      _subscriptionsParcelPlanInfo.tr;

  static const String _subscriptionsParcelFooterNote =
      'subscriptions_parcel_footer_note';
  static String get subscriptionsParcelFooterNote =>
      _subscriptionsParcelFooterNote.tr;

  static const String _currencySar = 'currency_sar';
  static String get currencySar => _currencySar.tr;

  // --- Loyalty ---
  static const String _loyaltyTitle = 'loyalty_title';
  static String get loyaltyTitle => _loyaltyTitle.tr;

  static const String _loyaltyAvailableBadge = 'loyalty_available_badge';
  static String get loyaltyAvailableBadge => _loyaltyAvailableBadge.tr;

  static const String _loyaltyProgressHeading = 'loyalty_progress_heading';
  static String get loyaltyProgressHeading => _loyaltyProgressHeading.tr;

  static const String _loyaltyProgressOfLabel = 'loyalty_progress_of_label';

  /// `{target}` in the translation is replaced with the ring's target count.
  static String loyaltyProgressOfLabel(int target) =>
      _loyaltyProgressOfLabel.tr.replaceFirst('{target}', '$target');

  static const String _loyaltyOrdersUnit = 'loyalty_orders_unit';
  static String get loyaltyOrdersUnit => _loyaltyOrdersUnit.tr;

  static const String _loyaltyRemainingOrdersTemplate =
      'loyalty_remaining_orders_template';

  /// Returns the translation with its `{count}` marker left intact — the
  /// caller splits on that literal marker to colour just the number, so this
  /// deliberately isn't a simple getter like the others above.
  static String get loyaltyRemainingOrdersTemplate =>
      _loyaltyRemainingOrdersTemplate.tr;

  static const String _loyaltyCompletedOrdersLabel =
      'loyalty_completed_orders_label';
  static String get loyaltyCompletedOrdersLabel =>
      _loyaltyCompletedOrdersLabel.tr;

  static const String _loyaltyNoSubscriptionNote =
      'loyalty_no_subscription_note';

  /// `{target}` in the translation is replaced with the orders needed per
  /// reward.
  static String loyaltyNoSubscriptionNote(int target) =>
      _loyaltyNoSubscriptionNote.tr.replaceFirst('{target}', '$target');

  static const String _loyaltyFreeDeliveryTitle = 'loyalty_free_delivery_title';
  static String get loyaltyFreeDeliveryTitle => _loyaltyFreeDeliveryTitle.tr;

  static const String _loyaltyFreeDeliverySubtitle =
      'loyalty_free_delivery_subtitle';

  /// `{target}` in the translation is replaced with the orders needed per
  /// reward. Shown while no free delivery is available.
  static String loyaltyFreeDeliverySubtitle(int target) =>
      _loyaltyFreeDeliverySubtitle.tr.replaceFirst('{target}', '$target');

  static const String _loyaltyFreeDeliveriesAvailable =
      'loyalty_free_deliveries_available';

  /// `{count}` in the translation is replaced with the unused free
  /// deliveries.
  static String loyaltyFreeDeliveriesAvailable(int count) =>
      _loyaltyFreeDeliveriesAvailable.tr.replaceFirst('{count}', '$count');

  static const String _loyaltyRecentOrdersTitle = 'loyalty_recent_orders_title';
  static String get loyaltyRecentOrdersTitle => _loyaltyRecentOrdersTitle.tr;

  static const String _loyaltyViewHistoryLink = 'loyalty_view_history_link';
  static String get loyaltyViewHistoryLink => _loyaltyViewHistoryLink.tr;

  static const String _loyaltyCompletedOrderLabel =
      'loyalty_completed_order_label';
  static String get loyaltyCompletedOrderLabel =>
      _loyaltyCompletedOrderLabel.tr;

  static const String _loyaltyOrderNowButton = 'loyalty_order_now_button';
  static String get loyaltyOrderNowButton => _loyaltyOrderNowButton.tr;

  // --- Orders ---
  static const String _ordersTitle = 'orders_title';
  static String get ordersTitle => _ordersTitle.tr;

  static const String _ordersCountLabel = 'orders_count_label';

  /// `{count}` in the translation is replaced with the total order count.
  static String ordersCountLabel(int count) =>
      _ordersCountLabel.tr.replaceFirst('{count}', '$count');

  static const String _ordersFilterAll = 'orders_filter_all';
  static String get ordersFilterAll => _ordersFilterAll.tr;

  static const String _ordersFilterCurrent = 'orders_filter_current';
  static String get ordersFilterCurrent => _ordersFilterCurrent.tr;

  static const String _ordersFilterPast = 'orders_filter_past';
  static String get ordersFilterPast => _ordersFilterPast.tr;

  static const String _ordersCurrentSectionTitle =
      'orders_current_section_title';
  static String get ordersCurrentSectionTitle => _ordersCurrentSectionTitle.tr;

  static const String _ordersStatusPending = 'orders_status_pending';
  static String get ordersStatusPending => _ordersStatusPending.tr;

  static const String _ordersStatusPreparing = 'orders_status_preparing';
  static String get ordersStatusPreparing => _ordersStatusPreparing.tr;

  static const String _ordersStatusAwaitingCourier =
      'orders_status_awaiting_courier';
  static String get ordersStatusAwaitingCourier =>
      _ordersStatusAwaitingCourier.tr;

  static const String _ordersStatusOnTheWay = 'orders_status_on_the_way';
  static String get ordersStatusOnTheWay => _ordersStatusOnTheWay.tr;

  static const String _ordersStatusCancelled = 'orders_status_cancelled';
  static String get ordersStatusCancelled => _ordersStatusCancelled.tr;

  static const String _ordersStatusRefunded = 'orders_status_refunded';
  static String get ordersStatusRefunded => _ordersStatusRefunded.tr;

  static const String _ordersItemsCount = 'orders_items_count';

  /// `{count}` in the translation is replaced with the order's item count.
  static String ordersItemsCount(int count) =>
      _ordersItemsCount.tr.replaceFirst('{count}', '$count');

  static const String _ordersTodayAt = 'orders_today_at';

  /// `{time}` in the translation is replaced with the order's time.
  static String ordersTodayAt(String time) =>
      _ordersTodayAt.tr.replaceFirst('{time}', time);

  static const String _ordersYesterdayAt = 'orders_yesterday_at';

  /// `{time}` in the translation is replaced with the order's time.
  static String ordersYesterdayAt(String time) =>
      _ordersYesterdayAt.tr.replaceFirst('{time}', time);

  static const String _ordersCurrentEmpty = 'orders_current_empty';
  static String get ordersCurrentEmpty => _ordersCurrentEmpty.tr;

  static const String _ordersPastEmpty = 'orders_past_empty';
  static String get ordersPastEmpty => _ordersPastEmpty.tr;

  static const String _ordersReorderOtherStoreBody =
      'orders_reorder_other_store_body';
  static String get ordersReorderOtherStoreBody =>
      _ordersReorderOtherStoreBody.tr;

  static const String _ordersReorderPartial = 'orders_reorder_partial';

  /// `{count}` in the translation is replaced with the lines left out.
  static String ordersReorderPartial(int count) =>
      _ordersReorderPartial.tr.replaceFirst('{count}', '$count');

  static const String _ordersReorderUnavailable = 'orders_reorder_unavailable';
  static String get ordersReorderUnavailable => _ordersReorderUnavailable.tr;

  static const String _ordersTrackButton = 'orders_track_button';
  static String get ordersTrackButton => _ordersTrackButton.tr;

  static const String _ordersPastSectionTitle = 'orders_past_section_title';
  static String get ordersPastSectionTitle => _ordersPastSectionTitle.tr;

  static const String _ordersNewestFirstLabel = 'orders_newest_first_label';
  static String get ordersNewestFirstLabel => _ordersNewestFirstLabel.tr;

  static const String _ordersStatusDelivered = 'orders_status_delivered';
  static String get ordersStatusDelivered => _ordersStatusDelivered.tr;

  static const String _ordersReorderButton = 'orders_reorder_button';
  static String get ordersReorderButton => _ordersReorderButton.tr;

  // --- Pharmacy ---
  static const String _pharmacyTitle = 'pharmacy_title';
  static String get pharmacyTitle => _pharmacyTitle.tr;

  static const String _pharmacySubtitle = 'pharmacy_subtitle';
  static String get pharmacySubtitle => _pharmacySubtitle.tr;

  static const String _pharmacySelectTitle = 'pharmacy_select_title';
  static String get pharmacySelectTitle => _pharmacySelectTitle.tr;

  static const String _pharmacySelectSubtitle = 'pharmacy_select_subtitle';
  static String get pharmacySelectSubtitle => _pharmacySelectSubtitle.tr;

  static const String _pharmacyRequestLabel = 'pharmacy_request_label';
  static String get pharmacyRequestLabel => _pharmacyRequestLabel.tr;

  static const String _pharmacyRequestHint = 'pharmacy_request_hint';
  static String get pharmacyRequestHint => _pharmacyRequestHint.tr;

  static const String _pharmacyAttachmentLabel = 'pharmacy_attachment_label';
  static String get pharmacyAttachmentLabel => _pharmacyAttachmentLabel.tr;

  static const String _pharmacyWarningNote = 'pharmacy_warning_note';
  static String get pharmacyWarningNote => _pharmacyWarningNote.tr;

  static const String _pharmacySubmitButton = 'pharmacy_submit_button';
  static String get pharmacySubmitButton => _pharmacySubmitButton.tr;

  static const String _pharmacyAddressLabel = 'pharmacy_address_label';
  static String get pharmacyAddressLabel => _pharmacyAddressLabel.tr;

  static const String _pharmacyAddressPlaceholder =
      'pharmacy_address_placeholder';
  static String get pharmacyAddressPlaceholder =>
      _pharmacyAddressPlaceholder.tr;

  static const String _pharmacyAddAddress = 'pharmacy_add_address';
  static String get pharmacyAddAddress => _pharmacyAddAddress.tr;

  static const String _pharmacyNoPharmacies = 'pharmacy_no_pharmacies';
  static String get pharmacyNoPharmacies => _pharmacyNoPharmacies.tr;

  static const String _pharmacyIssueNoPharmacy = 'pharmacy_issue_no_pharmacy';
  static String get pharmacyIssueNoPharmacy => _pharmacyIssueNoPharmacy.tr;

  static const String _pharmacyIssueNoAddress = 'pharmacy_issue_no_address';
  static String get pharmacyIssueNoAddress => _pharmacyIssueNoAddress.tr;

  static const String _pharmacyIssueNoContent = 'pharmacy_issue_no_content';
  static String get pharmacyIssueNoContent => _pharmacyIssueNoContent.tr;

  static const String _pharmacyImageTooLarge = 'pharmacy_image_too_large';
  static String get pharmacyImageTooLarge => _pharmacyImageTooLarge.tr;

  static const String _pharmacyImageUnsupported = 'pharmacy_image_unsupported';
  static String get pharmacyImageUnsupported => _pharmacyImageUnsupported.tr;

  static const String _pharmacyTakePhoto = 'pharmacy_take_photo';
  static String get pharmacyTakePhoto => _pharmacyTakePhoto.tr;

  static const String _pharmacyChoosePhoto = 'pharmacy_choose_photo';
  static String get pharmacyChoosePhoto => _pharmacyChoosePhoto.tr;

  static const String _pharmacyRemovePhoto = 'pharmacy_remove_photo';
  static String get pharmacyRemovePhoto => _pharmacyRemovePhoto.tr;

  static const String _pharmacySentTitle = 'pharmacy_sent_title';
  static String get pharmacySentTitle => _pharmacySentTitle.tr;

  // --- Account ---
  static const String _accountTitle = 'account_title';
  static String get accountTitle => _accountTitle.tr;

  static const String _accountEditButton = 'account_edit_button';
  static String get accountEditButton => _accountEditButton.tr;

  static const String _accountMemberSince = 'account_member_since';

  /// `{year}` in the translation is replaced with the join year.
  static String accountMemberSince(int year) =>
      _accountMemberSince.tr.replaceFirst('{year}', '$year');

  static const String _accountSettingsSectionTitle =
      'account_settings_section_title';
  static String get accountSettingsSectionTitle =>
      _accountSettingsSectionTitle.tr;

  static const String _accountMyInfoTitle = 'account_my_info_title';
  static String get accountMyInfoTitle => _accountMyInfoTitle.tr;

  static const String _accountMyInfoSubtitle = 'account_my_info_subtitle';
  static String get accountMyInfoSubtitle => _accountMyInfoSubtitle.tr;

  static const String _accountAddressesTitle = 'account_addresses_title';
  static String get accountAddressesTitle => _accountAddressesTitle.tr;

  static const String _accountAddressesSubtitle = 'account_addresses_subtitle';
  static String get accountAddressesSubtitle => _accountAddressesSubtitle.tr;

  static const String _accountSubscriptionsTitle =
      'account_subscriptions_title';
  static String get accountSubscriptionsTitle => _accountSubscriptionsTitle.tr;

  static const String _accountSubscriptionsSubtitleNone =
      'account_subscriptions_subtitle_none';
  static String get accountSubscriptionsSubtitleNone =>
      _accountSubscriptionsSubtitleNone.tr;

  static const String _accountLoyaltyTitle = 'account_loyalty_title';
  static String get accountLoyaltyTitle => _accountLoyaltyTitle.tr;

  static const String _accountLoyaltySubtitle = 'account_loyalty_subtitle';

  /// `{completed}` and `{target}` in the translation are replaced with the
  /// loyalty progress counts.
  static String accountLoyaltySubtitle(int completed, int target) =>
      _accountLoyaltySubtitle.tr
          .replaceFirst('{completed}', '$completed')
          .replaceFirst('{target}', '$target');

  static const String _accountLoyaltySubtitleFallback =
      'account_loyalty_subtitle_fallback';

  /// Shown while progress is loading or couldn't be fetched.
  static String get accountLoyaltySubtitleFallback =>
      _accountLoyaltySubtitleFallback.tr;

  // --- Edit profile ---
  static const String _editProfileTitle = 'edit_profile_title';
  static String get editProfileTitle => _editProfileTitle.tr;

  static const String _editProfileSuccess = 'edit_profile_success';
  static String get editProfileSuccess => _editProfileSuccess.tr;

  // --- Addresses ---
  static const String _addressesEmpty = 'addresses_empty';
  static String get addressesEmpty => _addressesEmpty.tr;

  static const String _addressesAddButton = 'addresses_add_button';
  static String get addressesAddButton => _addressesAddButton.tr;

  static const String _addressDeleteConfirmTitle =
      'address_delete_confirm_title';
  static String get addressDeleteConfirmTitle => _addressDeleteConfirmTitle.tr;

  static const String _addressDeleteConfirmMessage =
      'address_delete_confirm_message';
  static String get addressDeleteConfirmMessage =>
      _addressDeleteConfirmMessage.tr;

  static const String _addressTypeHome = 'address_type_home';
  static String get addressTypeHome => _addressTypeHome.tr;

  static const String _addressTypeOffice = 'address_type_office';
  static String get addressTypeOffice => _addressTypeOffice.tr;

  static const String _addressTypeOther = 'address_type_other';
  static String get addressTypeOther => _addressTypeOther.tr;

  static const String _addAddressTitle = 'add_address_title';
  static String get addAddressTitle => _addAddressTitle.tr;

  static const String _addressTypeLabel = 'address_type_label';
  static String get addressTypeLabel => _addressTypeLabel.tr;

  static const String _addressLocationLabel = 'address_location_label';
  static String get addressLocationLabel => _addressLocationLabel.tr;

  static const String _addressMapHint = 'address_map_hint';
  static String get addressMapHint => _addressMapHint.tr;

  static const String _addressLocateButton = 'address_locate_button';
  static String get addressLocateButton => _addressLocateButton.tr;

  static const String _addressLocationPicked = 'address_location_picked';
  static String get addressLocationPicked => _addressLocationPicked.tr;

  static const String _addressLocationRequired = 'address_location_required';
  static String get addressLocationRequired => _addressLocationRequired.tr;

  static const String _addressDetailsLabel = 'address_details_label';
  static String get addressDetailsLabel => _addressDetailsLabel.tr;

  static const String _addressDetailsHint = 'address_details_hint';
  static String get addressDetailsHint => _addressDetailsHint.tr;

  static const String _addressContactNameLabel = 'address_contact_name_label';
  static String get addressContactNameLabel => _addressContactNameLabel.tr;

  static const String _addressContactNameHint = 'address_contact_name_hint';
  static String get addressContactNameHint => _addressContactNameHint.tr;

  static const String _addressContactPhoneLabel = 'address_contact_phone_label';
  static String get addressContactPhoneLabel => _addressContactPhoneLabel.tr;

  static const String _addressAdded = 'address_added';
  static String get addressAdded => _addressAdded.tr;

  /// 403 `coordinates` — the point is outside every delivery zone.
  static const String _addressOutOfCoverage = 'address_out_of_coverage';
  static String get addressOutOfCoverage => _addressOutOfCoverage.tr;

  // --- Device location ---
  static const String _locationServiceDisabled = 'location_service_disabled';
  static String get locationServiceDisabled => _locationServiceDisabled.tr;

  static const String _locationPermissionDenied = 'location_permission_denied';
  static String get locationPermissionDenied => _locationPermissionDenied.tr;

  static const String _locationPermissionDeniedForever =
      'location_permission_denied_forever';
  static String get locationPermissionDeniedForever =>
      _locationPermissionDeniedForever.tr;

  static const String _locationUnavailable = 'location_unavailable';
  static String get locationUnavailable => _locationUnavailable.tr;

  static const String _comingSoon = 'coming_soon';
  static String get comingSoon => _comingSoon.tr;

  static const String _accountHelpTitle = 'account_help_title';
  static String get accountHelpTitle => _accountHelpTitle.tr;

  static const String _accountHelpSubtitle = 'account_help_subtitle';
  static String get accountHelpSubtitle => _accountHelpSubtitle.tr;

  static const String _accountLogoutButton = 'account_logout_button';
  static String get accountLogoutButton => _accountLogoutButton.tr;

  // --- Delete account ---
  static const String _accountDeleteButton = 'account_delete_button';
  static String get accountDeleteButton => _accountDeleteButton.tr;

  static const String _accountDeleteTitle = 'account_delete_title';
  static String get accountDeleteTitle => _accountDeleteTitle.tr;

  static const String _accountDeleteConsequences =
      'account_delete_consequences';
  static String get accountDeleteConsequences => _accountDeleteConsequences.tr;

  static const String _accountDeleteAcknowledge = 'account_delete_acknowledge';
  static String get accountDeleteAcknowledge => _accountDeleteAcknowledge.tr;

  static const String _accountDeleteConfirm = 'account_delete_confirm';
  static String get accountDeleteConfirm => _accountDeleteConfirm.tr;

  /// HTTP 203 `on-going` — an order is still in progress.
  static const String _accountDeleteOngoingOrder =
      'account_delete_ongoing_order';
  static String get accountDeleteOngoingOrder => _accountDeleteOngoingOrder.tr;

  static const String _accountDeleted = 'account_deleted';
  static String get accountDeleted => _accountDeleted.tr;

  static const String _accountAppearanceTitle = 'account_appearance_title';
  static String get accountAppearanceTitle => _accountAppearanceTitle.tr;

  static const String _accountAppearanceSubtitle =
      'account_appearance_subtitle';
  static String get accountAppearanceSubtitle => _accountAppearanceSubtitle.tr;

  static const String _accountFooterTagline = 'account_footer_tagline';
  static String get accountFooterTagline => _accountFooterTagline.tr;

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

  // --- Notifications ---
  static const String _notificationsTitle = 'notifications_title';
  static String get notificationsTitle => _notificationsTitle.tr;

  /// The bell's tooltip / screen-reader label.
  static const String _notificationsOpen = 'notifications_open';
  static String get notificationsOpen => _notificationsOpen.tr;

  static const String _notificationsMarkAllRead = 'notifications_mark_all_read';
  static String get notificationsMarkAllRead => _notificationsMarkAllRead.tr;

  static const String _notificationsMarkAllFailed =
      'notifications_mark_all_failed';
  static String get notificationsMarkAllFailed =>
      _notificationsMarkAllFailed.tr;

  static const String _notificationsEmptyTitle = 'notifications_empty_title';
  static String get notificationsEmptyTitle => _notificationsEmptyTitle.tr;

  static const String _notificationsEmptyMessage =
      'notifications_empty_message';
  static String get notificationsEmptyMessage => _notificationsEmptyMessage.tr;

  /// Screen-reader hint on an unread row (the dot is visual only).
  static const String _notificationsUnread = 'notifications_unread';
  static String get notificationsUnread => _notificationsUnread.tr;

  static const String _notificationsTimeNow = 'notifications_time_now';
  static String get notificationsTimeNow => _notificationsTimeNow.tr;

  static const String _notificationsTimeMinutes = 'notifications_time_minutes';
  static String notificationsTimeMinutes(int minutes) =>
      _notificationsTimeMinutes.tr.replaceFirst('{n}', '$minutes');

  static const String _notificationsTimeHours = 'notifications_time_hours';
  static String notificationsTimeHours(int hours) =>
      _notificationsTimeHours.tr.replaceFirst('{n}', '$hours');

  static const String _notificationsTimeYesterday =
      'notifications_time_yesterday';
  static String get notificationsTimeYesterday =>
      _notificationsTimeYesterday.tr;
}
