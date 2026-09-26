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

  // --- Restaurants ---
  static const String _restaurantsTitle = 'restaurants_title';
  static String get restaurantsTitle => _restaurantsTitle.tr;

  static const String _restaurantsSubtitle = 'restaurants_subtitle';
  static String get restaurantsSubtitle => _restaurantsSubtitle.tr;

  static const String _restaurantsFilterNearest = 'restaurants_filter_nearest';
  static String get restaurantsFilterNearest => _restaurantsFilterNearest.tr;

  static const String _restaurantsFilterTopRated =
      'restaurants_filter_top_rated';
  static String get restaurantsFilterTopRated => _restaurantsFilterTopRated.tr;

  static const String _restaurantsFilterFastest = 'restaurants_filter_fastest';
  static String get restaurantsFilterFastest => _restaurantsFilterFastest.tr;

  static const String _restaurantsSectionTitle = 'restaurants_section_title';
  static String get restaurantsSectionTitle => _restaurantsSectionTitle.tr;

  static const String _restaurantsBadgeTodayOffer =
      'restaurants_badge_today_offer';
  static String get restaurantsBadgeTodayOffer =>
      _restaurantsBadgeTodayOffer.tr;

  // --- Store details ---
  static const String _storeDetailsOpenNowBadge =
      'store_details_open_now_badge';
  static String get storeDetailsOpenNowBadge => _storeDetailsOpenNowBadge.tr;

  static const String _storeDetailsTabMostOrdered =
      'store_details_tab_most_ordered';
  static String get storeDetailsTabMostOrdered =>
      _storeDetailsTabMostOrdered.tr;

  static const String _storeDetailsTabMeals = 'store_details_tab_meals';
  static String get storeDetailsTabMeals => _storeDetailsTabMeals.tr;

  static const String _storeDetailsTabAddons = 'store_details_tab_addons';
  static String get storeDetailsTabAddons => _storeDetailsTabAddons.tr;

  static const String _storeDetailsSectionTitle =
      'store_details_section_title';
  static String get storeDetailsSectionTitle => _storeDetailsSectionTitle.tr;

  static const String _storeDetailsAddonsTitle = 'store_details_addons_title';
  static String get storeDetailsAddonsTitle => _storeDetailsAddonsTitle.tr;

  static const String _storeDetailsCartViewButton =
      'store_details_cart_view_button';
  static String get storeDetailsCartViewButton =>
      _storeDetailsCartViewButton.tr;

  static const String _storeDetailsCartCount = 'store_details_cart_count';

  /// `{count}` in the translation is replaced with the live cart total —
  /// the only translation key in this file that needs a parameter.
  static String storeDetailsCartCount(int count) =>
      _storeDetailsCartCount.tr.replaceFirst('{count}', '$count');

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

  static const String _orderConfirmationDeliveryFeeSectionTitle =
      'order_confirmation_delivery_fee_section_title';
  static String get orderConfirmationDeliveryFeeSectionTitle =>
      _orderConfirmationDeliveryFeeSectionTitle.tr;

  static const String _orderConfirmationAreaCardSubtitle =
      'order_confirmation_area_card_subtitle';
  static String get orderConfirmationAreaCardSubtitle =>
      _orderConfirmationAreaCardSubtitle.tr;

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

  // --- Subscriptions ---
  static const String _subscriptionsTitle = 'subscriptions_title';
  static String get subscriptionsTitle => _subscriptionsTitle.tr;

  static const String _subscriptionsSubtitle = 'subscriptions_subtitle';
  static String get subscriptionsSubtitle => _subscriptionsSubtitle.tr;

  static const String _subscriptionsAreaSelectorTitle =
      'subscriptions_area_selector_title';
  static String get subscriptionsAreaSelectorTitle =>
      _subscriptionsAreaSelectorTitle.tr;

  static const String _subscriptionsAreaFeeNote =
      'subscriptions_area_fee_note';

  /// `{area}` and `{fee}` in the translation are replaced with the
  /// currently-selected area's name and delivery fee.
  static String subscriptionsAreaFeeNote(String area, int fee) =>
      _subscriptionsAreaFeeNote.tr
          .replaceFirst('{area}', area)
          .replaceFirst('{fee}', '$fee');

  static const String _subscriptionsBestValueBadge =
      'subscriptions_best_value_badge';
  static String get subscriptionsBestValueBadge =>
      _subscriptionsBestValueBadge.tr;

  static const String _subscriptionsFooterNote = 'subscriptions_footer_note';
  static String get subscriptionsFooterNote => _subscriptionsFooterNote.tr;

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
  static String get loyaltyNoSubscriptionNote => _loyaltyNoSubscriptionNote.tr;

  static const String _loyaltyFreeDeliveryTitle = 'loyalty_free_delivery_title';
  static String get loyaltyFreeDeliveryTitle => _loyaltyFreeDeliveryTitle.tr;

  static const String _loyaltyFreeDeliverySubtitle =
      'loyalty_free_delivery_subtitle';
  static String get loyaltyFreeDeliverySubtitle =>
      _loyaltyFreeDeliverySubtitle.tr;

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
  static String get ordersCurrentSectionTitle =>
      _ordersCurrentSectionTitle.tr;

  static const String _ordersViewTrackingLink = 'orders_view_tracking_link';
  static String get ordersViewTrackingLink => _ordersViewTrackingLink.tr;

  static const String _ordersStatusPreparing = 'orders_status_preparing';
  static String get ordersStatusPreparing => _ordersStatusPreparing.tr;

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

  static const String _accountAddressesSubtitle =
      'account_addresses_subtitle';
  static String get accountAddressesSubtitle => _accountAddressesSubtitle.tr;

  static const String _accountSubscriptionsTitle =
      'account_subscriptions_title';
  static String get accountSubscriptionsTitle =>
      _accountSubscriptionsTitle.tr;

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

  static const String _accountHelpTitle = 'account_help_title';
  static String get accountHelpTitle => _accountHelpTitle.tr;

  static const String _accountHelpSubtitle = 'account_help_subtitle';
  static String get accountHelpSubtitle => _accountHelpSubtitle.tr;

  static const String _accountLogoutButton = 'account_logout_button';
  static String get accountLogoutButton => _accountLogoutButton.tr;

  static const String _accountAppearanceTitle = 'account_appearance_title';
  static String get accountAppearanceTitle => _accountAppearanceTitle.tr;

  static const String _accountAppearanceSubtitle = 'account_appearance_subtitle';
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
