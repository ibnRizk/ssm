# SSM Ecosystem Readiness Report

**Scope:** Customer app (`ssm`), Merchant app (`merchant`), Driver app (`ssm_driver`), each at the head of `main` as of 2026-10-06.
**Method:** A static, read-only analysis and a logical dry run of every E2E flow, traced through routes, cubits, repositories, data sources and the API guides in each repo's `docs/`. No code was run and no live backend was called. Where the backend's behaviour is assumed, the report says so.

---

## 1. Overall verdict: **NOT READY**

The core happy path of Flow A works on paper. Every status transition has a button, an endpoint, an `Idempotency-Key` and optimistic locking, and the three apps share one canonical status vocabulary. The ecosystem still can't launch, for five reasons:

| # | Blocker | Why it stops launch |
|---|---|---|
| **1** | **No push and no realtime in any of the three apps.** There is no FCM and no WebSocket/Pusher client, even though the backend already documents both (FCM token routes, `/broadcasting/auth`, `.ssm.order.status_changed`). | A merchant with the app in the background never hears about a new order. A driver who switches to Google Maps (the app's own "Open Google Maps" button) stops receiving offers. The customer learns about status changes only while the tracking screen is open. |
| **2** | **The driver app stops reporting its location as soon as it leaves the foreground.** It has only foreground timers, no background-location permission, no foreground service, and no `UIBackgroundModes`. | Navigating to the store or customer in Google Maps puts the app in the background. iOS suspends it straight away, and Android soon after. The heartbeat goes stale (120 s server window), so the driver drops out of dispatch, and the customer's "live location" goes stale mid-delivery. |
| **3** | **Parcel delivery can't be completed with an OTP.** The driver app asks for the recipient's 6-digit OTP, but the customer app has no parcel OTP screen and no endpoint for one. | Every parcel falls back to the "location + time" proof, so no parcel delivery has a cryptographic handover. |
| **4** | **Release builds for Merchant and Driver are signed with the debug key** (`merchant/android/app/build.gradle.kts:48`, `ssm_driver/android/app/build.gradle.kts:51`). | Google Play rejects them. |
| **5** | **There's no recovery path when something goes wrong mid-order.** The customer can't cancel after the merchant accepts, the customer's Help & Support screen is "Coming soon", the merchant has no cancel command, and the driver has no "can't pick up / can't deliver / release order" command. The driver's "Report a problem" also sends a hardcoded test note. | Any real-world exception (store closed, item out of stock, customer unreachable) leaves an order stuck with nobody able to move it, except an admin on the backend. |

**Test-credential note.** The driver credential `01030841336` is an Egyptian mobile number, but the driver app hard-prefixes `+966` (`ssm_driver/lib/core/utils/string_extension.dart:16-21`), so it sends `+9661030841336`. Unless the driver was registered with exactly that string, the dry-run login fails at step one. The ecosystem also mixes markets: Customer and Driver are Saudi (`+966`, SAR), while the Merchant app has Egyptian defaults (`+20` hint, map centred on Mansoura, "Nabra Governorate" copy). The customer (`0509775370` → `+966509775370`) and merchant (e-mail) credentials normalise correctly.

---

## 2. Flow & sequence blockers

### 2.1 Flow A: standard order, step by step

| Step | Actor / app | What the code does | Endpoint | Verdict |
|---|---|---|---|---|
| A1 Browse and add to cart | Customer | Zone headers, store list, cart CRUD | `/stores/*`, `/customer/cart/*` | ✅ |
| A2 Quote and place | Customer | Server quote (`order/quote`). Place is COD only, with one `Idempotency-Key` per attempt that is reused while a request is in progress (`checkout_cubit.dart:93-130`) | `POST /customer/order/place` | ✅ |
| A3 Post-place navigation | Customer | `go(home)` then `push(orderTracking/:id)` (`order_confirmation_screen.dart:279-281`) | — | ✅ |
| A4 Merchant receives the order | Merchant | Polls `current-orders` every 15 s, **only while the screen is visible and the app is in the foreground** (`core/widgets/refresh_poller.dart`). No sound, vibration, push or badge. | `GET /vendor/current-orders` | ❌ **Blocker 1.** A backgrounded merchant misses orders. |
| A5 Accept / reject | Merchant | `expected_version` plus `Idempotency-Key`, with typed reject reasons. A 409 or 422 shows a conflict notice and reloads the list. | `POST /vendor/orders/{id}/accept\|reject` | ✅ |
| A6 Start preparing | Merchant | `nextAction` = `start-preparing` | `…/start-preparing` | ✅ |
| A7 Ready for pickup (starts dispatch) | Merchant | `nextAction` = `ready-for-pickup`. The merchant then sees `dispatching` / `driver_assigned` / `driver_accepted` as labels only. | `…/ready-for-pickup` | ✅ API. ⚠️ The merchant never sees **who** is coming: there's no driver name, phone or ETA in the order model, so the merchant can't check the courier's identity at handover. |
| A8 Driver receives the offer | Driver | `OfferPollingCubit` polls `active-offer` every 5 s **only while the driver is online and the process is alive**. The offer sheet rings and counts down from the server's `remaining_seconds`. | `GET /delivery-man/active-offer` | ⚠️ Works in the foreground only (Blocker 1 and 2). A ~30 s offer window against a 5 s poll leaves about 25 s to respond. |
| A9 Accept the offer | Driver | Idempotent accept. On success it loads `current-work` and pushes `orderTrip`. A 409 re-reads the offer. | `POST /delivery-man/offers/{id}/accept` | ✅ |
| A10 Navigate to the store | Driver | `NavigateToStoreScreen` → "Open Google Maps" → **"Confirm"** (`navigate_to_store_screen.dart:93-95`) is a purely client-side push to Pickup Confirmation. | none | ⚠️ **There's no "Arrived at store" state or endpoint.** Merchant and customer can't see that the driver arrived, and opening Maps backgrounds the app (Blocker 2). |
| A11 Pickup | Driver | A static, non-interactive checklist ("bag count", "sealed", "number matches"), then `confirmPickup`. | `POST /delivery-man/orders/{id}/pickup` | ⚠️ The checklist asks the driver to check the bag count and order number, but `current-work` carries **no items, bag count or pickup code** (`current_work.dart`). The checklist is decorative. |
| A12 Out for delivery | Driver | "Start delivery" button | `…/out-for-delivery` | ✅ |
| A13 Customer gets the OTP | Customer | Tracking polls every 15 s while the screen is open and in the foreground. On `out_for_delivery` it requests the OTP once; requesting again replaces the code. | `POST /customer/orders/{id}/delivery-otp/request` | ⚠️ The customer gets the OTP **only if the tracking screen is open**. There's no push to bring them there, and the Orders list doesn't refresh itself. |
| A14 Driver validates the OTP | Driver | Six-digit check, idempotent per OTP value, `cod_collected` = `isCashOnDelivery` | `POST /delivery-man/orders/{id}/complete` (`proof_method: otp`) | ✅. ⚠️ Next to it is **"Complete with location"**, which completes **without any customer OTP** (`proof_of_delivery_screen.dart:107`). It's always available, so OTP is effectively optional unless the backend enforces a geofence. |
| A15 Finish | Driver → Home; Customer sees "Delivered" | `goNamed(home)` and stats refresh. Customer polling stops on `delivered`. | — | ✅ |

**Flow A navigation dead-ends and gaps**

1. **No "Arrived" step** (A10). The "Confirm" button on Navigate-to-Store doesn't tell the backend anything.
2. **Pickup has no exit except success.** "Report a problem" (`report_problem_sheet.dart:49-50, 128`) sends the hardcoded note `'Test report from the driver app (placeholder UI)'`. By design it **never changes order status** (`next_action: continue_order`), so a driver at a closed store has no way to release the order.
3. **No way to report a problem after pickup.** The report button exists only on Pickup Confirmation, so there's nothing for "customer unreachable", "wrong address" or "refused". The only way out is to complete the order with location proof, which marks it **delivered**.
4. **The driver's delivery screens never re-read `current-work`.** They don't poll and don't listen to the app lifecycle (`ssm_driver/lib/features/orders/presentation/screens/*`). If an admin cancels or reassigns the order, the driver stays on a stale screen until the next command fails.
5. **The merchant Order Details screen has no "Retry dispatch" button.** Retry lives only on the Active Orders card (`active_orders_screen.dart:135`, `collapsed_active_order_card.dart:100-114`), and `OrderDetailsCubit` has no `retryDispatch`. The details screen also doesn't poll.
6. **The customer tracking screen has no map.** The driver's location shows as the text "Live" / "Unavailable" (`order_tracking_screen.dart` `_Contact`), even though `google_maps_flutter` is a dependency and the tracking payload carries coordinates.

### 2.2 Flow B: parcel delivery, step by step

| Step | App | What the code does | Verdict |
|---|---|---|---|
| B1 Parcel created | Admin/backend | No app involvement | — |
| B2 Driver assigned | Driver | Shows up in `GET /delivery-man/parcels?status=active` **only when the driver opens or refreshes** Home or Parcels. No push and no polling. | ⚠️ |
| B3 Pickup from warehouse | Driver | **No pickup action.** The statuses are only `ARRIVED_AT_WAREHOUSE → OUT_FOR_DELIVERY → DELIVERED`. "Start delivery" is optional (API §13), so the warehouse handover is never recorded. | ⚠️ A process gap (needs a backend/product decision) |
| B4 Customer tracks and sets drop-off | Customer | `ParcelsScreen` loads once and on pull-to-refresh only, with no polling. The drop-off is `POST /customer/parcels/{id}/location`, allowed in any state except delivered, with **no `Idempotency-Key`**. The status mapping guesses 20+ spellings because the API doesn't document them (`parcel_model.dart:56-80`). | ⚠️ |
| B5 Driver sees the updated drop-off | Driver | `ParcelDetailsScreen` reads the parcel once, with no polling or lifecycle refresh. A drop-off the customer changes **after the driver opens the parcel** isn't seen until a manual reload. | ❌ Driver may go to the old address |
| B6 Complete | Driver | OTP or location proof. Parcel commands have **no `Idempotency-Key`** (the docs say a repeat is idempotent). | ❌ **Blocker 3.** The customer app has no way to show a parcel OTP, so OTP completion can't happen in practice. |
| B7 Customer sees "Delivered" | Customer | Only after a manual refresh | ⚠️ |

**Flow B dead-ends:** OTP proof can't be used (B6). There's no warehouse pickup event (B3). The customer can change the drop-off while the parcel is out for delivery, but the driver never sees the change (B4/B5). A parcel with no drop-off yet can still be started by the driver, who then has no coordinates to navigate to.

### 2.3 State-machine mismatches across apps

| Canonical `ssm_status` | Merchant `OrderStatus` | Customer tracking `OrderStatus` | Customer orders list (`order_status`, legacy) | Driver `WorkStatus` |
|---|---|---|---|---|
| `pending_merchant` | ✅ | ✅ | `pending` | — |
| `accepted` / `preparing` / `ready_for_pickup` | ✅ | ✅ | `accepted`/`confirmed`/`processing` → preparing. `handover` → awaiting courier. | — |
| `dispatching` / `driver_assigned` | ✅ | ✅ | **unknown → "pending"** | — |
| `driver_accepted` / `picked_up` / `out_for_delivery` | ✅ | ✅ | `picked_up` → on the way | ✅ |
| `delivered` | ✅ | ✅ | ✅ | ✅ |
| `rejected` / `cancelled` | ✅ | ✅ (terminal) | `canceled`/`failed` → cancelled | ❌ not modelled |
| **`assignment_failed`** | ✅ recoverable (`isActive`, `canRetryDispatch`) | ❌ **treated as final.** Polling stops (`order_status.dart:46-52`). | unknown → "pending" | — |
| `failed` / `refunded` | ✅ | ❌ unknown → null → `resolve()` falls back to **pending**. A refunded order shows "Placed" and is polled forever. | `refunded` ✅ | — |

**Critical mismatch: `assignment_failed`.** The merchant treats it as recoverable (retry dispatch), but the customer app treats it as terminal. Polling stops, the order leaves the timeline, and the customer sees a failure headline. When the merchant presses **Retry dispatch** and a driver accepts, the customer screen **never updates again** until they leave and re-open it. If they never re-open it, they never get the delivery OTP.

---

## 3. Cross-app synchronization & state timing

| Scenario | What actually happens |
|---|---|
| **Customer cancels while the merchant is preparing** | Not possible from the UI: cancel shows only while `pending_merchant` (`canBeCancelled`). If a cancel and an accept race, the backend's 403 is handled: "can't cancel" toast, then a re-read. After acceptance the customer has **no cancel and no support channel** (Help & Support goes to `ComingSoonScreen`, `ssm/lib/config/routes/app_routes.dart:464-468`). The only option is calling the store. |
| **Admin/backend cancels while preparing** | The merchant list catches it on the next 15 s poll, or a command returns 409/422 and the list reloads with a conflict notice (fixed since the earlier merchant audit). Merchant **Order Details** doesn't poll, so it stays stale until the next action. The order then drops out of `current-orders` without saying why. |
| **Cancel after the driver accepted** | The driver app doesn't model `cancelled` and doesn't poll `current-work` during delivery. The driver finds out only when pickup or complete fails. Failures that aren't network errors do set `shouldRefreshWork`, so the work is re-read and the screen falls back to "no active work". There's no explanation. |
| **Driver rejects, or the offer expires** | The driver sheet closes. The backend re-offers. Merchant and customer see `dispatching` on their next poll. ✅ |
| **No driver found** | Backend → `assignment_failed`. **Merchant:** the Active Orders card shows "Retry dispatch" (✅ list, ❌ details screen). The backend's `.ssm.dispatch.assignment_failed` realtime event isn't used, so the merchant notices only on the next poll *if the screen is open*. **Customer:** polling stops for good (see 2.3). |
| **Merchant rejects** | The customer sees "Rejected" (terminal). ✅ The reason isn't shown (it isn't in the tracking payload). |
| **Enum parity** | Canonical strings match exactly across Merchant (`order_status.dart`), Customer (`order_tracking_models.dart:83-98`) and Driver (`current_work.dart`). Problems: the customer drops `failed`/`refunded`; the customer **list** still uses legacy `order_status`; the driver drops `cancelled`. Parcel statuses are uppercase (`ARRIVED_AT_WAREHOUSE`) for the driver, while the customer parses a lowercase guess list. Both work today only because the customer lowercases and guesses broadly. |
| **Polling cadence** | Customer tracking: 15 s, paused in the background, stops on final. Merchant: 15 s, only when visible and in the foreground. Driver offers: 5 s. Driver location and heartbeat: 20 s against a 120 s server freshness window. Customer orders list, customer parcels, driver current-work and driver parcels: **never auto-refresh**. |
| **Error recovery** | Strong for commands: idempotency keys are reused after network failures in Merchant and Driver order commands, plus `expected_version` locking, 409 re-reads and generation counters against stale responses. Weak for passive state: nothing reconnects or catches up except on screen re-entry or app resume (where wired). |

---

## 4. Edge cases & missing functions

| Area | Finding |
|---|---|
| **Network failure** | Commands: handled. The idempotency key is kept and a retry replays safely (driver `order_lifecycle_cubit.dart`, merchant `orders_repository_impl.dart`, customer checkout). Polls fail quietly by design. Customer tracking shows a "may be out of date" flag. There's no global offline banner in any app, even though `connectivity_plus` is a dependency of all three. |
| **Driver location permission: "While using"** | Requested at go-online, with a banner that deep-links to app or location settings (`LocationTrackingCubit.resolveIssue`). ✅ |
| **Driver background location** | ❌ Not requested anywhere. There's no `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE` or `POST_NOTIFICATIONS` in the Android manifest, no `NSLocationAlwaysAndWhenInUseUsageDescription` or `UIBackgroundModes` (`location`) in `Info.plist`, and no foreground-service plugin. The class doc admits it: *"Background updates on a locked phone would need a foreground service … which this app doesn't request"* (`location_tracking_cubit.dart`). **Blocker 2.** |
| **Merchant location permission** | The location picker centres on a fixed coordinate (31.03, 31.385, Mansoura, Egypt) and doesn't explain a denied permission. |
| **401 (session expired)** | All three apps: an interceptor sends a 401 on token-bearing requests to `AuthEventBus` → login. ✅ |
| **403 (suspended / not approved mid-session)** | Merchant: handled (`emitAccountRestricted`). Customer: mapped per call. **Driver: no global 403 handling** (`ssm_driver/lib/core/api/app_interceptors.dart` handles only 401). A driver suspended mid-shift keeps polling and gets logged failures (`OfferPollingCubit` only `Log.w`s). The UI looks online, but no offers will ever arrive. |
| **App killed while online** | The server marks the driver stale after 120 s with no heartbeat. Nothing tells the driver they're "offline", and the toggle may still read online on relaunch until `availability.load()` returns. |
| **Mid-delivery app restart** | Driver: `current-work` restores the active order. ✅ Customer: tracking re-opens from the Orders list. ✅ |
| **Driver can't complete** | There's no "failed delivery / return to store" command or flow. |
| **COD confirmation** | `cod_collected` is sent as `isCashOnDelivery` automatically. The driver never confirms the cash was actually received. |
| **Force update / maintenance** | Customer has `/config/customer`. Merchant has `/vendor/config`. The driver app has no config or min-version check. |
| **Notifications inbox** | The backend has a notifications inbox for customer and merchant. Neither app has a notifications screen. |

---

## 5. Missing features & APIs (checklist)

### P0: must be built before launch
- [ ] **FCM in all three apps.** Firebase setup, then the token routes: `PUT /customer/cm-firebase-token` and `POST /customer/remove-fcm-token`; `POST /vendor/update-fcm-token` and `/vendor/remove-fcm-token`; `PUT /delivery-man/update-fcm-token`. Data-message handling then refetches over REST and deep-links (order → tracking, offer → offer sheet, new order → Orders tab).
- [ ] **Realtime (Pusher protocol)** at least for merchant orders and customer tracking: `POST /broadcasting/auth`, then subscribe to `private-merchant.{id}`, `private-customer.{id}` and `private-order.{id}`. Handle `.ssm.order.status_changed`, `.ssm.dispatch.assignment_failed` and `.ssm.driver.location_updated`.
- [ ] **Driver background location.** An Android foreground service with a persistent notification, `ACCESS_BACKGROUND_LOCATION` plus `FOREGROUND_SERVICE_LOCATION`, an iOS `location` background mode with the Always-permission strings, and an in-app disclosure screen. Google Play requires a prominent disclosure for background location.
- [ ] **Parcel OTP for the recipient.** A backend endpoint (e.g. `POST /customer/parcels/{id}/delivery-otp/request`, or SMS to `recipient_phone`) and a customer-app OTP card, matching the order OTP card. Or make `LOCATION_TIME` the explicit, documented parcel proof.
- [ ] **Customer tracking: `assignment_failed` is not final.** Keep polling, and show "Finding a new courier…".
- [ ] **Driver exception path.** A backend command to release, or fail pickup or delivery (e.g. `POST /delivery-man/orders/{id}/release` or `/fail-delivery` with a reason), plus the app flow. Make "Report a problem" available after pickup too.
- [ ] **Report-a-problem note field.** Replace the hardcoded `_placeholderNote` with real input (`report_problem_sheet.dart:49-50`).
- [ ] **Customer Help & Support screen**, replacing `ComingSoonScreen`. Feed it from `/config/customer` support fields.
- [ ] **Release signing** for Merchant and Driver (`key.properties`, as the customer app already does).
- [ ] **Resolve the driver phone format** for non-Saudi numbers, or confirm that drivers are Saudi-only and fix the test data.

### P1: should ship at launch
- [ ] An "Arrived at store" / "Arrived at customer" command and timestamps (backend and driver app), shown to the merchant and customer.
- [ ] Driver identity on the merchant order (name, phone, vehicle plate) for handover.
- [ ] Order items, bag count or pickup code in `current-work`, so the pickup checklist can actually be checked.
- [ ] A "Retry dispatch" button on merchant **Order Details**, and polling on that screen.
- [ ] The driver's delivery and parcel screens should poll `current-work` / `parcels/{id}` (or listen to push) so cancels and drop-off changes reach the driver.
- [ ] Auto-refresh for the customer Orders list and Parcels screen, or push-driven refresh.
- [ ] Driver global 403 handling (`driver-not-approved` / suspended) that stops polling and routes to the onboarding status screen.
- [ ] A customer map with the driver's live position (the payload already carries coordinates).
- [ ] An explicit "Cash received" confirmation before sending `cod_collected: true`.
- [ ] `Idempotency-Key` on parcel completion and the customer drop-off POST (needs backend support), for parity with order commands.
- [ ] Gate or remove location-only completion for orders. At minimum, the backend should enforce a geofence and an "OTP attempted" rule.
- [ ] Map `failed` / `refunded` canonical statuses in the customer app. Move the customer Orders list to `ssm_status` once the list endpoint returns it.
- [ ] Merchant: an audible or vibrating alert for new orders while the app is in the foreground.

### P2: post-launch
- [ ] A notifications inbox screen (customer and merchant; the endpoints exist).
- [ ] Merchant order-history export (button currently shows "coming soon": `order_history_screen.dart:105-108`).
- [ ] A driver config / min-version endpoint and force-update check.
- [ ] A global offline banner using `connectivity_plus`.
- [ ] Online payment for customer subscriptions. Purchase currently creates an unpaid intent that an admin approves.

---

## 6. Static data purge list

| # | App | Location | Hardcoded value | Replace with |
|---|---|---|---|---|
| S1 | Driver | `lib/features/orders/presentation/widgets/report_problem_sheet.dart:49-50` | `'Test report from the driver app (placeholder UI)'` is **sent to the backend** | User-entered note |
| S2 | Customer, Merchant, Driver | `lib/core/utils/values/launch_url_method.dart:13-14` (all three repos) | `https://wa.me/+20$url` (Egypt prefix, `//todo remove +20`) | E.164 number from config |
| S3 | Driver | `lib/core/utils/string_extension.dart:16-21` | Forces `+966` on any number without a `+`, so `01030841336` → `+9661030841336` | Country from zone/config, or validate Saudi-only |
| S4 | Merchant | `lib/features/auth/presentation/pages/register_screen.dart:241` | Phone hint `'+20 1X XXXX XXXX'` | Market-specific hint |
| S5 | Merchant | `lib/features/auth/presentation/pages/location_picker_screen.dart:17` | `LatLng(31.0300, 31.3850)` (Mansoura) | Zone centre from config |
| S6 | Customer | `lib/features/addresses/presentation/widgets/address_map_picker.dart:22` | `LatLng(21.2146, 41.6330)` fallback centre | `default_map_center` from `/config/customer` |
| S7 | Customer | `lib/features/pharmacy/presentation/cubit/pharmacy_order_cubit.dart:30` | `pharmacyCategoryId = 3` | Category id from config |
| S8 | Customer | `lib/config/routes/app_routes.dart:464-468` | Help & Support → `ComingSoonScreen` | Real screen |
| S9 | Customer | `lib/features/loyalty/presentation/widgets/loyalty_content.dart:78, 110` | Two `onTap: () {}` / `onPressed: () {}` CTAs (with TODOs) | Navigate to order history / Home |
| S10 | Merchant | `lang/en.json:168`, `lang/ar.json:168` (`local_time_note`) | "Local time: **Nabra Governorate**" | Store zone and timezone from server |
| S11 | Merchant | `lang/*.json` `free_trial_banner`, used at `login_screen.dart:119` and `profile_screen.dart:265` | "No fees or commission during the first phase" (a business promise) | Show only when a config flag says the trial is active |
| S12 | Merchant | `lang/*.json` `onboarding_orders_body` | "New orders reach you **instantly**" (false without push) | Ship push, or change the copy |
| S13 | Merchant | `lang/*.json` `management_monitors`, used in `orders_screen.dart` | Internal-facing copy | Copy review |
| S14 | Merchant | `order_history_screen.dart:105-108` | Export → "coming soon" snackbar | Hide or implement |
| S15 | Driver | `lang/*.json` `parcelSourceDescription`, `parcelTourStatus` (used in `parcel_details_source_card.dart:59`, `parcels_summary_card.dart:69`) | "Ready for local delivery in **Turabah**", "Turabah • Ready to Start" | The driver's zone name (already on the profile payload) |
| S16 | Driver | `lib/core/services/driver_stats/incentive_summary.dart:7` | `IncentiveRule.rewardAmount = '5.00'` (shown on Earnings) | From `incentive-summary` |
| S17 | Driver | `lib/features/earnings/presentation/screens/earnings_screen.dart:210-215` | "Submit" CTA only shows "settlement is manual" | Settlement API, or remove the button |
| S18 | Driver | `lib/features/orders/presentation/screens/pickup_confirmation_screen.dart:73-77` | Static verification checklist, not tied to data | Real items, bag count or pickup code |
| S19 | Driver | `lib/features/subscriptions/presentation/screens/subscriptions_screen.dart` (uses `subscriptionsMockTitle`, `subMockPeriod/Guarantee/Hours`; `onPressed: () {}` at :142) | Fully mock screen. **No route reaches it**, so it's dead code. | Delete, or build it |
| S20 | Driver | `lang/*.json` and `core/utils/values/strings.dart` | ~25 unused `*Mock*` keys (`orderMockCustomer`, `homeMockCashTotal "640 SAR"`, `profileMockName`, …) and `earningsLastUpdated: "Updated 5 minutes ago"` | Delete |
| S21 | Customer / Merchant | `lib/core/widgets/modal_bottom_sheet_scaffold.dart` (`onPressed: () {}`) | An invisible spacer `IconButton` that's still tappable and announced by screen readers | Use a `SizedBox` |
| S22 | Customer | `checkout/data/models/requests/place_order_body.dart:11` | `payment_method: 'cash_on_delivery'` only | Payment methods from config, when online payment ships |
| S23 | Customer | `order_quote_model.dart:37`, `parcel_model.dart:42`, `subscription_plan_model.dart:39` | `?? 'SAR'` currency fallback | Acceptable if Saudi-only; otherwise use zone currency |

No static prices or delivery fees were found in the order path: fees and totals come from `order/quote`, and the Merchant and Driver apps use server amounts as strings.

---

## 7. Actionable recommendations (in order)

1. **Pick one launch market and make the three apps agree on it.** Choose country code, currency, map centre and copy, then fix S2–S6, S10 and S15, and re-seed the driver test account so `01030841336` can log in, or use a Saudi test number.
2. **Wire up push first, realtime second.** The backend contracts already exist. Treat every message as "refetch over REST", which the apps' repositories already support. This one change removes most of Section 3's timing problems.
3. **Make the driver app a proper background location app.** Add a foreground service, background permission with disclosure, and keep the heartbeat and location loop alive while a delivery is active and while the driver is online in another app (Google Maps).
4. **Fix the `assignment_failed` mismatch** in the customer app. It's a few lines in `order_status.dart`, and a regression test is needed per CLAUDE.md §7.
5. **Close the exception paths.** Product and backend decide the driver release/fail commands and customer post-accept cancellation or support. Then build them, and replace the report-problem placeholder note.
6. **Settle parcel proof.** Either add a recipient OTP channel or formally drop OTP for parcels. Add a warehouse pickup event and refresh on the driver side.
7. **Configure release signing** for Merchant and Driver, and confirm the iOS permission strings match actual behaviour. The merchant `Info.plist` currently requests "Always" location for a map pin, which App Review will question.
8. **Clean up hardcoded data** (Section 6): delete the mock strings and the unreachable driver Subscriptions screen, and hide the "coming soon" CTAs.
9. **Run a real E2E pass** on staging with the three apps on three physical devices (one iOS), including: app in the background during dispatch, the driver in Google Maps for 5+ minutes, a cancel race at accept, a no-driver → retry dispatch, airplane mode during `complete`, and a token revoked mid-delivery.

---

### Appendix: what's solid

- **Command safety:** `Idempotency-Key` with reuse-on-network-retry and `expected_version` optimistic locking on every merchant and driver order command, and on customer order placement.
- **One canonical status vocabulary** across the three apps for the order path.
- **Clean layering:** Cubit → repository → data source, `Either<Failure, T>` at the boundary, and sealed states. Test suites exist: Merchant 65, Customer 59 and Driver 44 test files.
- **Stale-response guards:** generation counters in the merchant cubits, `isClosed`/`isFinal` checks in customer tracking, and offer countdown against the server deadline in the driver app.
- **401 handling** sends the user to login in all three apps.
