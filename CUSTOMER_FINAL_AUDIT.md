# SSM Customer App: Final Pre-Launch Audit

| | |
|---|---|
| **Date** | 2026-10-01 |
| **Codebase** | `master` @ `31d953c` (327 Dart files, ~25k LOC, 15 features) |
| **Contract audited against** | [docs/SSM_CUSTOMER_API_GUIDE.md](docs/SSM_CUSTOMER_API_GUIDE.md) and [docs/SSM_CUSTOMERcollection.json](docs/SSM_CUSTOMERcollection.json) |
| **Method** | Read every file under `lib/`. Compared each screen against the endpoint list. Searched for hardcoded data, no-op handlers, TODOs, and missing UI states. Traced the order, parcel, pharmacy, subscription, and auth journeys from start to finish. |

**Priority legend**

- **P0, launch blocker.** A store-review rejection, a broken core journey, a security problem, or a customer charged or misled.
- **P1, must fix before public launch.** Visible gaps that hurt trust or support load.
- **P2, can ship after launch.** Polish and planned features.

---

## 0. Executive Summary

The architecture is sound. Layers are clean, every cubit uses a sealed state, failures are typed, and cubit and data-layer tests exist for every feature. Most screens handle loading, error, and retry. What's missing is mostly **product surface**, not code quality.

- Several endpoints that the backend already provides are not wired up.
- Several features that customers expect have no backend at all.
- A few journeys stop dead with nowhere to go.

### Top launch blockers

| # | Blocker | Owner | Ref |
|---|---|---|---|
| 1 | **No in-app account deletion.** App Store Guideline 5.1.1(v) and Google Play both require it. No endpoint and no UI. | BE + FE + Design | A1.1 |
| 2 | **No "forgot password".** A customer who forgets their password is locked out for good. | BE + FE + Design | A1.2 |
| 3 | **The customer confirms a COD order without seeing the delivery fee or final total.** The server's `total_ammount` is parsed and then dropped. | BE + FE | A1.3, C1.4 |
| 4 | **No push notifications at all.** There is no FCM package and the token is never registered, so status changes are only visible while the tracking screen is open. | FE (BE contract) | A2.1, C2 |
| 5 | **The customer cannot cancel an order in the app.** `PUT /customer/order/cancel` exists but is not used. | FE + Design | C2 |
| 6 | **Tracking can poll forever on a cancelled order** if the cancellation happens before the merchant acts. | FE + BE | C1.1, A2.2 |
| 7 | **Help & Support is a "Coming soon" page.** There are no Terms or Privacy links either, which both stores require. | BE + FE + Design | A1.8, B2 |
| 8 | **The release build is signed with the debug keystore**, and `debugPrint` writes full API response bodies (names, phones, addresses) to device logs in release. | FE | C3 |
| 9 | **A bearer token is committed in source**, inside a comment in `app_interceptors.dart`. | FE + BE (revoke) | C3.1 |
| 10 | **Subscription and loyalty free deliveries are never shown or applied at checkout.** The customer cannot tell whether the benefit they paid for or earned was used. | BE + FE | A1.4 |

---

## A. Backend API Requirements

### A1. Missing endpoints (net-new backend work)

None of these exist in the Postman collection. I searched it for `review`, `rating`, `favorite`, `wish`, `coupon`, `promo`, `chat`, `forgot`, `reset-password`, and `remove-account`, with zero matches.

| # | Pri | Capability | Suggested contract | Why |
|---|---|---|---|---|
| A1.1 | **P0** | **Delete account** | `DELETE /customer/remove-account` → 200. Anonymize PII and revoke Passport tokens. Refuse with 409 `active-orders` while orders are running. | Required by both stores. Currently there is no way to do it. |
| A1.2 | **P0** | **Password reset** | `POST /auth/forgot-password {phone}` → OTP sent. `POST /auth/verify-reset-otp {phone, otp}` → `reset_token`. `POST /auth/reset-password {reset_token, password}`. Throttled the same way as login. | Login is phone + password only ([login_request.dart](lib/features/auth/data/models/requests/login_request.dart)). There is no recovery path. |
| A1.3 | **P0** | **Order quote before placing** | `POST /customer/order/quote {store_id, address_id or lat/lng}` → `{subtotal, delivery_fee, tax, discount, free_delivery_source: null\|"subscription"\|"loyalty", total, cod_limit, store_open, minimum_order}`. Uses the same pricing engine as `order/place`. | The cart and checkout can only say "fee calculated on confirm" ([order_confirmation_summary_card.dart:45-48](lib/features/checkout/presentation/widgets/order_confirmation_summary_card.dart#L45-L48)). The customer agrees to an unknown COD amount. |
| A1.4 | **P0** | **How subscriptions and loyalty apply to an order** | Document whether `order/place` uses an active subscription or a loyalty free delivery automatically, or needs a flag such as `use_free_delivery: true`. Return `free_delivery_applied`, `free_delivery_source`, and `delivery_fee_waived` in the place response and in the order details. | Customers buy plans ([subscriptions_cubit.dart](lib/features/subscriptions/presentation/cubit/subscriptions_cubit.dart)) and earn rewards ([loyalty_free_delivery_card.dart](lib/features/loyalty/presentation/widgets/loyalty_free_delivery_card.dart)). Nothing in the order flow mentions either. |
| A1.5 | **P1** | **Rate the order, store, and driver** | `POST /customer/orders/{id}/review {store_rating 1-5, driver_rating 1-5, comment?, item_ratings?[]}`. Allowed once, after `delivered`. `GET /stores/{id}/reviews?offset&limit`. Return `can_review: bool` on the order. | Store cards show `avg_rating` ([store_card.dart:136-151](lib/features/catalog/presentation/widgets/store_card.dart#L136-L151)), but customers have no way to feed it, so every store shows "New" forever. |
| A1.6 | **P1** | **Promo codes** | `POST /customer/coupon/apply {code, store_id}` → `{discount, type, min_order, expires_at}` or 422 with a code (`expired`, `min-order`, `not-applicable`). Accept `coupon_code` on `order/place`. Optional: `GET /customer/coupon/list`. | Checkout has no discount line. Home already shows a static "Discount" badge ([home_subscription_banner.dart:40-46](lib/features/home/presentation/widgets/home_subscription_banner.dart#L40-L46)). |
| A1.7 | **P1** | **Contact the driver** | Pick one: (a) a masked-number proxy, `POST /customer/orders/{id}/call-driver` → temporary number, or (b) in-app chat, `GET/POST /customer/orders/{id}/messages` plus a realtime event. | The guide says the driver's phone is intentionally hidden. The tracking screen shows the driver's name but gives no way to reach them ([order_tracking_screen.dart:149-157](lib/features/order_tracking/presentation/screens/order_tracking_screen.dart#L149-L157)). |
| A1.8 | **P0** | **App config: support and legal** | `GET /config/customer` → `{support_phone, support_whatsapp, support_email, terms_url, privacy_url, faq_url, min_supported_version_android/ios, pharmacy_category_id, default_map_center, cod_max_amount}` | Help & Support is a placeholder ([app_routes.dart:429-434](lib/config/routes/app_routes.dart#L429-L434)). The pharmacy category is hardcoded to `3` ([pharmacy_order_cubit.dart:30](lib/features/pharmacy/presentation/cubit/pharmacy_order_cubit.dart#L30)). There's no force-update check ([splash_screen.dart:38-49](lib/features/splash/presentation/screens/splash_screen.dart#L38-L49)). |
| A1.9 | **P1** | **Favorite stores** | `GET /customer/wish-list`, `POST /customer/wish-list/add {store_id}`, `DELETE /customer/wish-list/remove?store_id=`. Return `is_favorite` on the store list and store details. | No favorites anywhere. |
| A1.10 | **P1** | **Home offers and banners** | `GET /banners?zone_id=` → `[{id, title, subtitle, image_url, action: {type: store\|category\|pharmacy\|subscriptions\|url, target}}]` | The Home "Offers near you" section is hardcoded copy with a hardcoded "Turbah · 10 SAR" label ([home_offers_section.dart:13-16](lib/features/home/presentation/widgets/home_offers_section.dart#L13-L16)). |
| A1.11 | **P1** | **Pharmacy request lifecycle** | Document the statuses (`submitted → quoted → accepted → converted_to_order / rejected / expired`). Add `POST /customer/pharmacy-requests/{id}/accept-quote` and `/reject-quote`. Return `quote_amount`, `quote_items`, `order_id` once converted. | After submitting, the customer sees a dialog and the screen closes ([pharmacy_order_screen.dart:303-322](lib/features/pharmacy/presentation/screens/pharmacy_order_screen.dart#L303-L322)). The guide never says how the request turns into a priced, delivered order. |
| A1.12 | **P1** | **Subscription payment path** | Either enable a gateway (`/customer/payments/*` is currently gated with 422) or return payment instructions (bank, IBAN, reference) from `purchase-intent`. Show `pending` intents in `/subscriptions/current` or `/history` with a `status`. Reject a duplicate pending intent with 409. | The app creates an unpaid intent and shows a snackbar ([subscriptions_screen.dart:155-161](lib/features/subscriptions/presentation/screens/subscriptions_screen.dart#L155-L161)). The customer isn't told how to pay, can't see the intent afterwards, and can create any number of them. |
| A1.13 | **P2** | **Verify a phone change** | Require an OTP when `update-profile` changes `phone`, for example `POST /customer/verify-phone`. | Today a customer can switch their login phone to any unused number with no verification ([edit_profile_cubit.dart:21-41](lib/features/account/presentation/cubit/edit_profile_cubit.dart#L21-L41)). |
| A1.14 | **P2** | **Profile photo** | `POST /customer/update-profile` as multipart with `image`. Return `image_full_url` from `/customer/info`. | Avatars are an initial letter ([account_profile_card.dart:102-115](lib/features/account/presentation/widgets/account_profile_card.dart#L102-L115)) or a generic icon ([home_header.dart:52-60](lib/features/home/presentation/widgets/home_header.dart#L52-L60)). |

### A2. Contract changes or clarifications on existing endpoints

| # | Pri | Endpoint | Ask |
|---|---|---|---|
| A2.1 | **P0** | `PUT /customer/cm-firebase-token` + push | Document the FCM payload: `{type: order_status\|parcel_status\|pharmacy_quote\|subscription_activated, entity_type, entity_id, ssm_status?}` so the app can deep-link. Confirm which events trigger a push. |
| A2.2 | **P0** | `GET /customer/orders/{id}/tracking` | `ssm_status` is `null` until the merchant acts. **Set it on every terminal transition**, including a cancel by the customer, admin, or a timeout before the merchant acts. Also return `cancellation_reason`, `cancelled_by: customer\|merchant\|admin\|system`, and `legacy_status` in the same payload. The app currently reads the legacy status only once (see C1.1). |
| A2.3 | **P0** | `POST /customer/order/place` | Support an `Idempotency-Key` header. A COD order that times out on a weak connection and is retried would otherwise create a duplicate. The guide says "Idempotency: not used". |
| A2.4 | **P1** | `POST /customer/order/place` | Document every refusal `errors[].code`. Only `coordinates` and `order_amount` are known today ([checkout_repository.dart:8-14](lib/features/checkout/domain/repos/checkout_repository.dart#L8-L14)). Needed: `store_closed`, `minimum_order`, `item_unavailable`, `zone_mismatch`. Without them, every other refusal shows raw server text. |
| A2.5 | **P1** | `GET /config/get-zone-id` | **The app calls this, but it's not in the customer contract or the Postman collection** ([api_endpoints.dart:44](lib/core/api/api_endpoints.dart#L44)). Either confirm it as supported or have the app switch to `GET /zone/check`. |
| A2.6 | **P1** | `GET /customer/parcels` | Document the parcel `status` values. The app guesses about 20 possible spellings ([parcel_model.dart:61-85](lib/features/parcels/data/models/parcel_model.dart#L61-L85)) and has no state for `cancelled`, `returned`, or `failed_delivery`. Document paging. Say whether parcels expose driver tracking or a delivery OTP the way orders do. |
| A2.7 | **P1** | `GET /stores/get-stores/all`, `/stores/search` | Add `sort=distance\|rating\|delivery_time` and `category_id` filters. The three sort chips have no API behind them ([restaurant_filter_chips.dart:13-14](lib/features/restaurants/presentation/widgets/restaurant_filter_chips.dart#L13-L14)). |
| A2.8 | **P1** | `GET /customer/order/list`, `running-orders` | Return `ssm_status` next to the legacy `order_status`. Today the Orders list (legacy mapping, [order_list_entry.dart:15-25](lib/features/orders/domain/entities/order_list_entry.dart#L15-L25)) and Tracking (`ssm_status`) can show **different statuses for the same order**. |
| A2.9 | **P1** | `GET /customer/order/details` | Return a receipt shape: lines with variations and add-ons, fees, discount, payment method, address, per-status timestamps, `can_cancel`, `can_review`. |
| A2.10 | **P2** | `POST /customer/cart/add` | Confirm whether items have variations or add-ons. Reorder deliberately drops them ([reorder_cubit.dart:16-17](lib/features/orders/presentation/cubit/reorder_cubit.dart#L16-L17)), and the menu has no picker. |
| A2.11 | **P2** | Realtime | The guide references `docs/SSM_REALTIME_MOBILE_CONTRACT.md` (`private-customer.{id}`, `ssm.order.status_changed`, `ssm.driver.location_updated`). **That file is not in this repo.** Please share it, along with the broadcaster type and its auth endpoint. |
| A2.12 | **P2** | 422 bodies | Always include `errors[].code` on 422 responses. The app currently drops the code for 422s ([api_error_mapper.dart:38-44](lib/core/api/api_error_mapper.dart#L38-L44)). |

### A3. Endpoints that already exist but the app doesn't use (frontend work, listed for visibility)

| Endpoint(s) | What it would unlock |
|---|---|
| `GET /customer/notifications`, `/unread-count`, `PATCH /{id}/read`, `POST /read-all` | Notification inbox and bell badge |
| `PUT /customer/cm-firebase-token` | Push notifications |
| `GET /customer/order/cancellation-reasons`, `PUT /customer/order/cancel` | Cancel a pending order |
| `PUT /customer/address/update/{id}` | Edit an address |
| `GET /items/search`, `GET /items/details/{id}` | Product search and item detail sheet |
| `GET /customer/subscriptions/history`, `/{id}`, `/{id}/usage` | Subscription history and usage |
| `GET /customer/loyalty/rewards` | Rewards list ("View history" is a no-op today) |
| `GET /customer/pharmacy-requests`, `/{id}`, `/{id}/prescription` | "My pharmacy requests" and their status |
| `GET /customer/parcels/{id}` | Parcel details |
| `GET /zone/check` | Supported replacement for `config/get-zone-id` |

---

## B. Design / UI Requirements

### B1. Hardcoded or static content that should be dynamic

| Pri | Where | What's static | Should be |
|---|---|---|---|
| **P1** | Home › Offers ([home_offers_section.dart:16](lib/features/home/presentation/widgets/home_offers_section.dart#L16)) | `'تربة · 10 ر.س'`: a fixed zone name and price, **Arabic only, untranslated**. The offer card always points to Pharmacy. | Banners from A1.10, or remove the section for launch |
| **P1** | Home › Subscription banner ([home_subscription_banner.dart](lib/features/home/presentation/widgets/home_subscription_banner.dart)) | A static "Discount / Save with SSM" card that **can't be tapped** | Tap opens Subscriptions. Show "N deliveries left" if the customer has an active plan. |
| **P1** | Home › header avatar ([home_header.dart:52-60](lib/features/home/presentation/widgets/home_header.dart#L52-L60)) | A generic person icon that can't be tapped | Profile initial or photo. Tap opens Account. |
| **P1** | Loyalty › app-bar badge ([loyalty_screen.dart:33-46](lib/features/loyalty/presentation/screens/loyalty_screen.dart#L33-L46)) | Always says "Available to everyone" | Remove it, or show the real reward state |
| **P1** | Loyalty › recent orders ([loyalty_recent_order_tile.dart](lib/features/loyalty/presentation/widgets/loyalty_recent_order_tile.dart)) | Identical "+1 completed order" tiles; the history entries are never parsed | Store name, date, and order number per entry |
| **P2** | Add Address › map ([address_map_picker.dart:22](lib/features/addresses/presentation/widgets/address_map_picker.dart#L22)) | Opens on fixed Turbah coordinates until GPS answers | `default_map_center` from config (A1.8) |
| **P2** | Add Address › location line ([address_location_field.dart:97-103](lib/features/addresses/presentation/widgets/address_location_field.dart#L97-L103)) | Shows **raw lat/lng** ("21.21460, 41.63300") to the customer | Reverse-geocoded street name |
| **P2** | Store card and store details | `distance` and `coverUrl` are parsed ([store_model.dart:37,45](lib/features/catalog/data/models/store_model.dart#L37)) but **never shown**. The store header is a plain navy block. | Distance chip on the card; cover photo in the details header |
| **P2** | Checkout › payment card ([order_confirmation_payment_card.dart](lib/features/checkout/presentation/widgets/order_confirmation_payment_card.dart)) | Static COD card | Add the zone's COD limit ("Max 500 SAR cash") from the quote (A1.3) |
| **P2** | Login › terms notice ([login_screen.dart:111-115](lib/features/auth/presentation/screens/login_screen.dart#L111-L115)) | "By continuing, you agree to our Terms… Privacy Policy" is plain text | Tappable links (A1.8) |

### B2. Controls that do nothing or mislead

| Pri | Control | Location | Current behaviour |
|---|---|---|---|
| **P0** | Help & Support row | Account tab → [app_routes.dart:429-434](lib/config/routes/app_routes.dart#L429-L434) | Opens a "Coming soon" screen |
| **P1** | "View history" link | Loyalty, [loyalty_content.dart:76-78](lib/features/loyalty/presentation/widgets/loyalty_content.dart#L76-L78) | `onTap: () {}` |
| **P1** | "Order now" CTA | Loyalty, [loyalty_content.dart:106-111](lib/features/loyalty/presentation/widgets/loyalty_content.dart#L106-L111) | `onPressed: () {}` |
| **P1** | Sort chips (Nearest / Top rated / Fastest) | Stores list, [restaurant_filter_chips.dart](lib/features/restaurants/presentation/widgets/restaurant_filter_chips.dart) | The highlight moves; the list never changes |
| **P1** | Pending parcel card with a chevron | [pending_shipment_card.dart:62-67](lib/features/parcels/presentation/widgets/pending_shipment_card.dart#L62-L67) | Shows a "tap me" chevron, but `onTap` is never passed ([parcels_tracking_section.dart:44-47](lib/features/parcels/presentation/widgets/parcels_tracking_section.dart#L44-L47)) |
| **P1** | Categories "View all" | Home, [home_categories_section.dart:41-42](lib/features/home/presentation/widgets/home_categories_section.dart#L41-L42) | Opens the *all stores* list, not a categories list. Home shows only 5 categories, so any beyond that can't be reached. |
| **P2** | "View cart" bar | Store details, [restaurant_cart_bar.dart](lib/features/restaurants/presentation/widgets/restaurant_cart_bar.dart) | Visible and tappable with 0 items. Shows the count, not the total. |
| **P2** | Add (+) button on menu items | [restaurant_product_card.dart:115-127](lib/features/restaurants/presentation/widgets/restaurant_product_card.dart#L115-L127) | Still active when the store is **closed**; the order is only refused at placement |

### B3. Screens and components that need a design (none exist today)

**P0**
1. **Delete account**: confirm, explain the consequences, re-enter password or OTP.
2. **Forgot password**: phone → OTP → new password.
3. **Cancel order**: bottom sheet with reasons from `cancellation-reasons`. Shown on the running-order card and on Tracking while the order is pending.
4. **Help & Support**: call, WhatsApp, email, FAQ, Terms, Privacy.
5. **Checkout price breakdown**: delivery fee, tax, discount, free-delivery source, total, and the COD limit warning.

**P1**

6. **Notification inbox** and a bell with an unread badge, on the Home header.
7. **Order details / receipt**: past-order cards are not tappable today ([past_order_card.dart](lib/features/orders/presentation/widgets/past_order_card.dart)).
8. **Rate your order**: prompt after delivery (Tracking) and an entry point from past orders.
9. **Live tracking map**: the driver location is fetched but shown only as "Live / Unavailable" text ([order_tracking_screen.dart:149-157](lib/features/order_tracking/presentation/screens/order_tracking_screen.dart#L149-L157)). `google_maps_flutter` is already a dependency.
10. **Terminal-state Tracking**: cancelled, rejected, and assignment-failed states with the reason and next actions (Reorder, Browse, Contact support). Today they show a generic headline and a timeline with only step 1 done.
11. **Delivery address and zone switcher on Home**: the customer can't see which address or zone the catalog is for. It's picked silently (C1.9). Only debug builds show "Zone: N" ([home_header.dart:66-83](lib/features/home/presentation/widgets/home_header.dart#L66-L83)).
12. **Global cart entry and badge**: the cart is only reachable from a store screen or via Reorder.
13. **Running-order banner on Home**: a "Your order is on the way" shortcut to Tracking.
14. **Item detail sheet**: image, description, quantity stepper, and add-ons if A2.10 applies.
15. **Product search results**: `/items/search`. Today search covers store names only.
16. **My pharmacy requests**: list, detail, quote, and accept/reject (A1.11).
17. **Subscription: pending / how to pay / history / usage** (A1.12).
18. **Edit address**, plus marking a default address.
19. **Parcel details**, and choosing the drop-off from a saved address or the map. Today it's device GPS only, which is wrong if the customer isn't at the drop-off point ([parcels_cubit.dart:95-96](lib/features/parcels/presentation/cubit/parcels_cubit.dart#L95-L96)).
20. **Force-update screen** and an **offline banner**. `connectivity_plus` is a dependency but unused.

**P2**

21. Favorites (heart on store card and details, plus a list).
22. Promo-code field at checkout.
23. Driver contact (call or chat) on Tracking.
24. Store reviews list.
25. Location-permission primer before the OS prompt.

### B4. Loading, empty, and error states by screen

Legend: ✅ present · ⚠️ basic (spinner, or text with no CTA or artwork) · ❌ missing

| Screen | Loading | Error + retry | Empty state | Notes |
|---|---|---|---|---|
| Splash | ✅ | ❌ | n/a | The token is never validated; an expired session drops to Login on the first 401 |
| Home | ⚠️ spinner | ✅ | ⚠️ text only ("No stores…") | No skeleton. A failed profile load is silent (falls back to a generic greeting, which is fine). |
| Stores list | ⚠️ | ✅ + load-more retry | ⚠️ text only | Empty search has no "clear search" CTA |
| Store details | ⚠️ (header preview ✅) | ✅ | ⚠️ "No items" text | No closed-store banner over the menu |
| Cart | ⚠️ | ✅ + action snackbars | ⚠️ "Your cart is empty" with **no "Browse stores" CTA** | |
| Checkout | ⚠️ addresses | ✅ | ✅ "Add address" | Fee and total unknown (A1.3) |
| Orders | ⚠️ | ✅ | ⚠️ text only, no "Start ordering" CTA | **Data goes stale; see C1.3** |
| Tracking | ⚠️ | ✅ + "may be out of date" note ✅ | n/a | Terminal states lack reason and CTA (B3.10) |
| Parcels | ⚠️ | ✅ + snackbar on refresh fail ✅ | ⚠️ "No parcels yet" with no explanation of how parcels arrive | Only the first page is loaded |
| Pharmacy | ⚠️ | ✅ | ⚠️ empty pharmacy picker | No list of past requests |
| Subscriptions | ⚠️ | ✅ (plans retry ✅) | ✅ "No plans" | Pending intent invisible (A1.12) |
| Loyalty | ⚠️ | ✅ | n/a | Two no-op CTAs (B2) |
| Account / Edit profile | ✅ card placeholder | ✅ | n/a | |
| Addresses | ⚠️ | ✅ | ✅ + Add button | |

**Cross-cutting design items**

- **No illustrations anywhere.** `assets/icons/` is empty, so every empty and error state falls back to a grey Material icon. Design should supply an illustration set for: empty cart, no orders, no parcels, no search results, offline, server error, out of coverage.
- **Spinners only, no skeletons.** `AppShimmer` exists in core but nothing uses it.
- **Dark mode is half-done.** The Account tab has a working dark-mode switch ([account_settings_section.dart:44-58](lib/features/account/presentation/widgets/account_settings_section.dart#L44-L58)), but the global `colors` getter is registered as light-only ([injection_container.dart:58](lib/injection_container.dart#L58)) and is used by bottom sheets, snackbars, dialogs, and the back button (C4.4). Bottom sheets stay white in dark mode. Either finish dark mode or hide the switch for launch.

---

## C. Frontend Technical Debt

### C1. Broken journeys and logic bugs

| # | Pri | Issue | Detail and fix |
|---|---|---|---|
| C1.1 | **P0** | **Tracking never re-reads the legacy status** | `refresh()` re-fetches only `/tracking` and resolves the status with `current.summary.legacyStatus` from the **first** load ([order_tracking_cubit.dart:98-101](lib/features/order_tracking/presentation/cubit/order_tracking_cubit.dart#L98-L101)). If an order is cancelled before the merchant acts (`ssm_status` still `null`), the screen shows "Order sent" and polls every 15 s forever. **Fix:** re-fetch `order/track` on each poll while `ssm_status == null`, and add a reproducing test. **Backend:** A2.2. |
| C1.2 | **P0** | **No cancel and no notifications** | Two related gaps: the customer can't cancel a pending order, and nothing tells them a status changed once they leave Tracking. There's no `firebase_messaging` in [pubspec.yaml](pubspec.yaml), and nobody calls `cm-firebase-token`. Polling stops when the screen is popped. |
| C1.3 | **P1** | **Orders tab goes stale** | `StatefulShellRoute.indexedStack` keeps the Orders branch alive ([app_routes.dart:197-216](lib/config/routes/app_routes.dart#L197-L216)), and nothing reloads it on tab re-entry or after a new order. If the customer has opened Orders before, a just-placed order won't appear until they pull to refresh. **Fix:** reload on tab focus, or broadcast an "order placed" event. |
| C1.4 | **P0** | **Server total ignored** | `PlacedOrder.totalAmount` is parsed ([placed_order_model.dart:26](lib/features/checkout/data/models/placed_order_model.dart#L26)), but the success listener only shows a generic snackbar ([order_confirmation_screen.dart:223-235](lib/features/checkout/presentation/screens/order_confirmation_screen.dart#L223-L235)). Show the confirmed total. `distance` is always sent as `0` ([place_order_body.dart:19](lib/features/checkout/data/models/requests/place_order_body.dart#L19)), which the backend accepts today but which is fragile. |
| C1.5 | **P1** | **Duplicate order on timeout** | A receive timeout on `order/place` shows "No internet", and pressing confirm again sends a second order. Until A2.3 lands, re-check `running-orders` before allowing a retry. |
| C1.6 | **P1** | **Closed store and minimum order not checked before placing** | `Store.isOpen` and `Store.minimumOrder` are parsed but never enforced in the menu, cart, or checkout. The customer only learns at placement, via an unmapped refusal message. |
| C1.7 | **P1** | **Phone call dials twice** | `makePhoneCall` calls `launchUrl` and then calls it again if the first succeeded ([launch_url_method.dart:37-38](lib/core/utils/values/launch_url_method.dart#L37-L38)). This affects "Call store" on Tracking. |
| C1.8 | **P1** | **WhatsApp helper hardcodes Egypt's country code** | `'https://wa.me/+20$url'`, with a `//todo` ([launch_url_method.dart:13-14](lib/core/utils/values/launch_url_method.dart#L13-L14)). It's unused today, but it will be the first thing Help & Support wires up. It also uses English-only error strings. |
| C1.9 | **P1** | **Zone chosen silently** | The zone is resolved from the *first* saved address, then from GPS, then from the *first service zone* ([zone_repository_impl.dart:76-98](lib/core/zone/zone_repository_impl.dart#L76-L98)). The customer can't see or change it. Checkout then *permanently* switches the zone to the chosen address ([checkout_repository_impl.dart:21-33](lib/features/checkout/data/repos/checkout_repository_impl.dart#L21-L33)), and deleting the active address leaves its zone in place. Needs the B3.11 switcher. |
| C1.10 | **P1** | **The 401 handler differs from logout** | The 401 listener clears only secure storage ([app.dart:33-38](lib/app.dart#L33-L38)), while `logout()` also clears the user and **zone ids** ([auth_repository_impl.dart:27-40](lib/features/auth/data/repos/auth_repository_impl.dart#L27-L40)). After an expired session, the next customer on the device inherits the previous zone. Home fires 3 calls at once, so one expired token causes 3 `go(login)` calls. The comment says "401/403" but only 401 is handled. **Fix:** route the 401 path through `AuthRepository.logout()` and debounce it. |
| C1.11 | **P1** | **Subscriptions default to the first zone** | Plans load for `zones.first`, not the customer's zone ([subscriptions_cubit.dart:51-57](lib/features/subscriptions/presentation/cubit/subscriptions_cubit.dart#L51-L57)). Customers outside zone 1 see the wrong prices. Default to `ZoneRepository.currentZoneIds`. |
| C1.12 | **P1** | **Pharmacy category is hardcoded** | `pharmacyCategoryId = 3` ([pharmacy_order_cubit.dart:30](lib/features/pharmacy/presentation/cubit/pharmacy_order_cubit.dart#L30)). It breaks silently if an admin re-creates categories. Read it from config (A1.8). |
| C1.13 | **P2** | **Parcels: first page only, one drop-off target** | No paging ([parcels_repository.dart:7](lib/features/parcels/domain/repos/parcels_repository.dart#L7)). Only one parcel at the warehouse gets an action card at a time ([parcel.dart:74-83](lib/features/parcels/domain/entities/parcel.dart#L74-L83)), so other parcels waiting for a location have no button. |
| C1.14 | **P2** | **Orders list vs Tracking status mismatch** | The list maps the legacy `order_status` while Tracking uses `ssm_status` (A2.8). Reorder is offered on cancelled orders, which may not be intended. |
| C1.15 | **P2** | **Splash doesn't validate the session** | It only checks that a token exists ([splash_screen.dart:42-48](lib/features/splash/presentation/screens/splash_screen.dart#L42-L48)) behind a fixed 1.4 s delay. The guide recommends `GET /customer/info`. |

### C2. Integration backlog (existing endpoints, see A3)

In order of value: **push (FCM) + notification inbox → cancel order → order details/receipt → address edit → item search and details → pharmacy request list/detail → subscription history and usage → parcel detail → loyalty rewards.** Each needs a remote data source method, a repository method, a cubit, tests, and the screen from B3.

### C3. Security and release configuration

| # | Pri | Issue | Location | Fix |
|---|---|---|---|---|
| C3.1 | **P0** | **Bearer token committed in a comment** | [app_interceptors.dart:22](lib/core/api/app_interceptors.dart#L22) | Delete the line. **Ask backend to revoke that Passport token** because it's in git history. |
| C3.2 | **P0** | **Release build signed with the debug key** | [android/app/build.gradle.kts:45-49](android/app/build.gradle.kts#L45-L49) | Add an upload keystore through `key.properties` (gitignored) and Play App Signing |
| C3.3 | **P0** | **PII written to device logs in release** | `debugPrint` of every error with the full response body ([app_interceptors.dart:65-67](lib/core/api/app_interceptors.dart#L65-L67)). `debugPrint` is not stripped in release. | Wrap it in `kDebugMode`, or route it through `Log` (whose default filter is debug-only) |
| C3.4 | **P1** | Router diagnostics in release | `debugLogDiagnostics: true` ([app_routes.dart:102](lib/config/routes/app_routes.dart#L102)) | `kDebugMode` |
| C3.5 | **P1** | No crash reporting or analytics | There's no Crashlytics or Sentry in [pubspec.yaml](pubspec.yaml) | Add one before launch, or production crashes are invisible |
| C3.6 | **P1** | Phone changed with no verification | [edit_profile_form.dart](lib/features/account/presentation/widgets/edit_profile_form.dart) | Depends on A1.13 |
| C3.7 | **P2** | Raw exception text can reach the user | The catch-all `ServerException(message: error.toString())` ([dio_consumer.dart:206-208](lib/core/api/dio_consumer.dart#L206-L208)) goes through `userMessage` | Use `ServerException()` with no message so the localized fallback is shown |
| C3.8 | **P2** | Placeholder Android `applicationId` TODO | [build.gradle.kts](android/app/build.gradle.kts) (`com.ssm.user`) | Confirm the final package id before the first store upload; it can't change later |

### C4. Code hygiene

| # | Pri | Item |
|---|---|---|
| C4.1 | P2 | **Unused boilerplate.** Never imported: `core/general_cubit/*`, `core/usecases/usecase.dart` (CLAUDE.md now says there's no UseCase layer), `core/utils/random_password.dart`, `convert_string_color.dart`, `date_format.dart`, and widgets `AppShimmer`, `LoadingView`, `CustomAlert`, `DiffImg`, `SearchTextField`, `AppTextField`, `TypeWriterEffect`, and `ShellTabPlaceholder` ([main_scaffold.dart:70-85](lib/config/routes/main_scaffold.dart#L70-L85)). Unused packages: `connectivity_plus`, `loading_animation_widget`. Remove them, or use them (shimmer, connectivity). |
| C4.2 | P2 | **Stale comments.** [orders_header.dart:12-13](lib/features/orders/presentation/widgets/orders_header.dart#L12-L13) mentions a `'ع'` placeholder that no longer exists. [account_header_bar.dart:8-9](lib/features/account/presentation/widgets/account_header_bar.dart#L8-L9) mentions a settings gear that isn't there. [pharmacy_dropdown_field.dart:8-9](lib/features/pharmacy/presentation/widgets/pharmacy_dropdown_field.dart#L8-L9) has a TODO that's already done. [pharmacy_order_screen.dart:31-33](lib/features/pharmacy/presentation/screens/pharmacy_order_screen.dart#L31-L33) calls the screen a "tab body", but it's a pushed route. [app.dart:31-32](lib/app.dart#L31-L32) says "401/403" and "swap for your login route once auth exists". |
| C4.3 | P2 | **Hardcoded English strings.** The `'No route found for …'` error pages ([app_routes.dart:166,295,357,437](lib/config/routes/app_routes.dart#L437)) and the `'Could not launch …'` snackbars in `launch_url_method.dart`. Move them to `lang/*.json`. |
| C4.4 | P2 | **Two color sources.** About 40 call sites in `core/widgets` use the global light-only `colors` instead of `context.colors` ([modal_bottom_sheet_scaffold.dart:32](lib/core/widgets/modal_bottom_sheet_scaffold.dart#L32), `app_snack_bar.dart`, `back_button.dart`, …). This is the cause of the dark-mode breakage in B4. The bottom-sheet header also has an invisible no-op `IconButton` used as a spacer ([modal_bottom_sheet_scaffold.dart:41-47](lib/core/widgets/modal_bottom_sheet_scaffold.dart#L41-L47)). |
| C4.5 | P2 | **The 422 mapper drops `errors[].code`** ([api_error_mapper.dart:38-44](lib/core/api/api_error_mapper.dart#L38-L44)), so the presentation layer can't branch on codes like `payment-gateway-unavailable` or `plan-404`. Map 422 to its own failure type that carries the code. |
| C4.6 | P2 | **Typo in a public API:** `Failure.addressmssage` ([address_messages.dart:17](lib/features/addresses/presentation/utils/address_messages.dart#L17)). The OTP expiry uses `DateFormat.Hm()` without a locale ([order_tracking_otp_card.dart:108](lib/features/order_tracking/presentation/widgets/order_tracking_otp_card.dart#L108)). |
| C4.7 | P2 | **`ReorderCubit` writes to the cart outside `CartCubit`'s serial queue.** This is safe only because no `CartCubit` lives inside a tab ([reorder_cubit.dart:19-23](lib/features/orders/presentation/cubit/reorder_cubit.dart#L19-L23)). A global cart badge (B3.12) would break that assumption, so move cart state to an app-scoped cubit at the same time. |
| C4.8 | P1 | **Test gaps.** Cubit and data tests are good (46 test files). Only **2** files contain widget tests and there are **no integration tests**. Before launch, add a reproducing test for C1.1, plus widget tests for checkout (address picker, refusal codes) and for the tracking screen's terminal states. Add one `integration_test` for login → browse → add → checkout → tracking. |

---

## Appendix: Suggested sequencing

1. **Week 1 (P0, can start in parallel):**
   - BE: A1.1, A1.2, A1.3, A1.4, A1.8, A2.1, A2.2, A2.3, and revoking the C3.1 token.
   - FE: C3.1–C3.3, C1.1, C1.7, FCM + inbox, cancel order.
   - Design: B3 items 1–5.
2. **Week 2 (P0 completion, P1):**
   - FE: wire the quote and free delivery into checkout; Help & Support and legal; delete account; forgot password; C1.3, C1.9–C1.12.
   - Design: B1, B2, B3 items 6–13, and the illustration set.
3. **Before submission:** fix or hide dark mode, add crash reporting, add the integration test, and run a store-compliance check covering account deletion, privacy links, and permission strings.
4. **After launch (P2):** reviews, promos, favorites, driver chat, item add-ons, profile photo, code hygiene (C4).
