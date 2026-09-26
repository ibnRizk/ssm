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

  static const String _homePharmacyCategory = 'home_pharmacy_category';
  static String get homePharmacyCategory => _homePharmacyCategory.tr;

  static const String _homeStoresTitle = 'home_stores_title';
  static String get homeStoresTitle => _homeStoresTitle.tr;

  static const String _homeStoresEmpty = 'home_stores_empty';
  static String get homeStoresEmpty => _homeStoresEmpty.tr;

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

  // --- Store (card & details) ---
  static const String _storeFreeDelivery = 'store_free_delivery';
  static String get storeFreeDelivery => _storeFreeDelivery.tr;

  static const String _storeDeliveryFrom = 'store_delivery_from';

  /// [amount] already carries its currency, e.g. `7 SAR`.
  static String storeDeliveryFrom(String amount) =>
      _storeDeliveryFrom.tr.replaceFirst('{amount}', amount);

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

  static const String _checkoutDeliveryFeeOnConfirm =
      'checkout_delivery_fee_on_confirm';
  static String get checkoutDeliveryFeeOnConfirm =>
      _checkoutDeliveryFeeOnConfirm.tr;

  static const String _checkoutOrderPlaced = 'checkout_order_placed';
  static String get checkoutOrderPlaced => _checkoutOrderPlaced.tr;

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
}
