# SSM Customer API Guide

For the Customer mobile engineer. Self-contained: you do not need the Merchant or Driver guides to build the Customer app. Every endpoint below is in `docs/postman/SSM_CUSTOMER_API.postman_collection.json` and was executed against the real Laravel implementation (see `docs/SSM_MOBILE_API_VERIFICATION_REPORT.md`, 97 of 97 requests pass).

Import `docs/postman/SSM_CUSTOMER_API.postman_collection.json` and `docs/postman/SSM_LOCAL.postman_environment.json`, set `base_url`, and run the folders in order (`01 Auth` first). IDs and tokens are saved to the environment automatically.

## 1. Conventions

| Item | Value |
|---|---|
| Base URL | `https://<host>/api/v1` |
| Format | JSON in/out. Send `Accept: application/json` always. |
| Language | `X-localization: en` or `ar` (titles/bodies of notifications and most messages are translated) |
| Zone headers | catalog, cart and order calls need `zoneId: [1]` (JSON array with the customer's current zone id) and `moduleId: 1`. Get the zone id from `POST /customer/address/add` (`zone_ids`) or `GET /zone/list`. |
| Auth | `Authorization: Bearer <token>` (Laravel Passport personal access token, valid about one year) |
| Idempotency | not used by the Customer API |

### Authentication (Customer only: Passport, not the same as Merchant/Driver)

- `POST /auth/sign-up` `{ "name", "phone", "email", "password" }` returns `{ "token": "..." }` and the customer is already signed in. `name` is one field ("First Last"). `phone` and `email` must be unique. `password` minimum 8 characters.
- `POST /auth/login` `{ "login_type": "manual", "email_or_phone": "+9665...", "field_type": "phone", "password": "..." }` returns `{ "token": "..." }`. `field_type` is `phone` or `email`.
- Wrong credentials: **401** `{ "errors": [{ "code": "auth-001", ... }] }`. Missing/invalid fields and duplicate phone/email: **403** with `errors` (a legacy convention of the auth controllers).
- There is **no logout endpoint** and no dedicated session-validate route: discard the token locally; use `GET /customer/info` to check that a stored token still works (**401** `{"message":"Unauthenticated."}` when it does not).
- Auth routes are throttled to 10 requests per minute per IP (**429**).
- Phone/e-mail OTP verification is a server setting; the tested environment has it off.

### Error shapes you must handle

| Situation | Status | Body |
|---|---|---|
| Not signed in / bad token | 401 | `{"message":"Unauthenticated."}` |
| Legacy validation (auth, cart, order, address) | 403 | `{"errors":[{"code":"field","message":"..."}]}` |
| SSM validation (notifications, pharmacy, parcels, payments) | 422 | `{"message":"...","errors":{"field":["..."]}}` or `{"errors":[{"code","message"}]}` |
| Not found or not yours | 404 (or 403 for `order/cancel`) | `{"message":"..."}` / `{"errors":[...]}` |
| Business-rule refusals in `order/place` | 203 or 403 | `{"errors":[{"code":"order_amount","message":"Amount crossed maximum cod order amount"}]}` |
| Too many requests | 429 | Laravel throttle body |

Do not rely on the wording of `message`; branch on the status and `errors[].code`. Resources you do not own always answer as if they did not exist.

## 2. Ordering flow

1. **Address**: `POST /customer/address/add` (`address_type`, `contact_person_name`, `contact_person_number`, `address`, `latitude`, `longitude`) returns the new `address_id`, `zone_ids`, and address object. Coordinates outside every zone: **403** code `coordinates`. `GET /customer/address/list` returns only the authenticated customer's addresses; `PUT /customer/address/update/{id}` and `DELETE /customer/address/delete?address_id=` return **404** for missing or foreign IDs.
2. **Browse**: `GET /stores/get-stores/all`, `GET /stores/details/{id}`, `GET /stores/search`, `GET /categories`, `GET /items/latest?category_id=0&store_id=..`, `GET /items/search`, `GET /items/details/{id}` (public).
3. **Cart**: `POST /customer/cart/add` `{ item_id, model: "Item", quantity, price }`, `POST /customer/cart/update` `{ cart_id, quantity }`, `GET /customer/cart/list`. An unknown or foreign `cart_id` returns **404**, never 500.
4. **Place**: `POST /customer/order/place` `{ order_type: "delivery", payment_method: "cash_on_delivery", store_id, order_amount, distance, address, latitude, longitude, contact_person_name, contact_person_number }`. The server builds the order from the cart and recomputes prices, tax and delivery fee; `order_amount` and `distance` are required by validation but are not authoritative. Response: `{ "message", "order_id", "total_ammount", "status": "pending", "created_at", "user_id" }` (`total_ammount` spelling is the real field name).
   - Payment: only `cash_on_delivery` is enabled. COD orders above the zone's maximum COD amount are refused (HTTP 203, code `order_amount`). Online payment is not enabled (see 8).
   - Refusals to expect: missing fields (403 with one error per field), coordinates outside the zone (403 `coordinates` "Out of coverage!"), store closed, etc.
5. **Track the state**: `GET /customer/order/running-orders`, `GET /customer/order/details?order_id=` (line items), `GET /customer/order/track?order_id=` (legacy summary with `order_status`), `GET /customer/order/list` (history).
6. **Cancel**: `PUT /customer/order/cancel` `{ order_id, reason }` works only while the order is still `pending` (before the merchant accepts). After that: **403** `You can not cancle after confirmed!` (the misspelling is the real message). A retry of a successful cancel returns 200 again without side effects.

### Canonical order status (what the Merchant and Driver drive)

`pending_merchant` -> `accepted` -> `preparing` -> `ready_for_pickup` -> `dispatching` -> `driver_assigned` -> `driver_accepted` -> `picked_up` -> `out_for_delivery` -> `delivered`. Terminal alternatives: `rejected` (merchant), `cancelled`, `assignment_failed` (no eligible driver).

The customer order endpoints above return the legacy `order_status` string. The canonical `ssm_status` is exposed by `GET /customer/orders/{order}/tracking` (it is `null` until the merchant first acts on the order; treat `null` as pending). Show progress from `ssm_status` when present.

## 3. Live tracking and delivery OTP

`GET /customer/orders/{order}/tracking` returns `{ order_id, ssm_status, tracking_allowed, driver, location, pickup, server_now }`.

- While `ssm_status` is `driver_accepted`, `picked_up` or `out_for_delivery`: `tracking_allowed: true`, `driver: { id, name }` (no phone) and `location: { latitude, longitude, accuracy, heading, speed, server_received_at, is_fresh }` (the latest coordinates the driver posted). `is_fresh` is false when the last location is older than the freshness window; show "location unavailable" then.
- In every other state, including **after delivery**, `driver` and `location` are `null`.
- Another customer's order returns **404**.

`POST /customer/orders/{order}/delivery-otp/request` (5 per minute) is allowed only while the order is `out_for_delivery`; it returns `{ "delivery_otp": { "challenge_id", "otp", "expires_at" } }`. **Show the 6-digit `otp` to the customer; the customer tells it to the Driver**, who completes the delivery with it. Otherwise **409** `otp-not-available`. Requesting again invalidates the previous code.

Realtime: subscribe to `private-customer.{id}` for `ssm.order.status_changed` and `ssm.driver.location_updated`; see `docs/SSM_REALTIME_MOBILE_CONTRACT.md`. Always reconcile against REST.

## 4. Notifications (inbox)

`GET /customer/notifications?per_page=20&status=all|read|unread` (per_page 1-50, else 422), `GET /customer/notifications/unread-count`, `PATCH /customer/notifications/{id}/read`, `POST /customer/notifications/read-all`. The list is a Laravel paginated resource (`data`, `links`, `meta`); each item is `{ id, type, title, body, entity: { type, id }, is_read, read_at, created_at, occurred_at }`, already translated. Reading someone else's notification returns **404**. Push (FCM) only wakes the app: fetch the inbox after.

Register the FCM token with `PUT /customer/cm-firebase-token` `{ cm_firebase_token }`.

## 5. Delivery subscriptions

`GET /customer/subscription-plans?zone_id=` (public) lists active plans (`deliveries_count`, `validity_days`, `price`, `currency`). `POST /customer/subscriptions/purchase-intent` `{ plan_id }` creates an **unpaid pending** subscription (HTTP **201**); online payment is not integrated, so an admin activates the subscription after payment. `GET /customer/subscriptions/current` returns the active subscription (`deliveries_total`, `deliveries_used`, `deliveries_remaining`, `expires_at`) or `data: null`. `GET /customer/subscriptions/history`, `/{id}`, `/{id}/usage`. Unknown plan: **404** `plan-404`.

## 6. Loyalty

`GET /customer/loyalty` returns `{ eligible_orders_required, current_progress, orders_remaining_for_next_reward, available_free_deliveries, lifetime_* }`; progress increases by one when an order is **delivered** (verified). `GET /customer/loyalty/history`, `GET /customer/loyalty/rewards`. This is independent of the legacy `loyalty_point` and `wallet_*` fields you may still see in `GET /customer/info`: ignore those.

## 7. Parcels and pharmacy requests

- **Parcels** (admin-created warehouse parcels delivered by an SSM Driver): `GET /customer/parcels`, `GET /customer/parcels/{id}`, `POST /customer/parcels/{id}/location` `{ latitude, longitude, delivery_address, notes }` (not allowed once delivered). The customer delivery fee is always `"0.00"` SAR (`customer_delivery_fee`, `customer_delivery_fee_currency`). `payment_type` is `PREPAID` (`cod_amount` 0) or `COD` (`cod_amount` due). Parcels belong to you by `customer_id` or recipient phone.
- **Pharmacy requests**: `POST /customer/pharmacy-requests` as **multipart** (`pharmacy_store_id`, `request_text`, `recipient_name`, `recipient_phone`, `delivery_address`, `latitude`, `longitude`, `prescription` image jpg/png/webp up to 10 MB). Either text or an image is required. **201** with the request and a price disclaimer (`warning`). `GET /customer/pharmacy-requests`, `/{id}`. The prescription is private: `has_prescription` and `attachment_meta` (`filename`, `mime_type`, `size_bytes`) are returned, never a storage path; the image is only available from `GET /customer/pharmacy-requests/{id}/prescription` with your bearer token (stream). Store must be an active pharmacy or **422**.

## 8. Payments (not enabled)

`POST /customer/payments/initiate` and `/verify` exist but every gateway is disabled: initiation returns **422** `payment-gateway-unavailable`. Do not build a payment UI yet.

## 9. Things the backend does that are easy to trip on

- Response statuses of legacy endpoints are not always 4xx for refusals (203 exists in `order/place`).
- `GET /customer/info` returns the customer profile but never returns password, remember token, FCM device token, temporary token, or e-mail verification token. Legacy wallet/loyalty values may still be present; use the dedicated SSM loyalty endpoints for loyalty UI.
- Order payloads contain a legacy `otp` field. It is **not** the delivery OTP; the delivery OTP only comes from the endpoint in section 3.
- `order/track` and `order/details` are legacy shapes; `tracking` is the SSM shape.

## 10. Endpoint reference (generated from the collection)

| Method | Path | Auth | Success / tested error statuses |
|---|---|---|---|
| **Auth** | | | |
| `POST` | `/auth/sign-up` | none | 200; errors: 403 |
| `POST` | `/auth/login` | none | 200; errors: 401, 403 |
| `GET` | `/customer/info` | Bearer | 200; errors: - |
| **Profile** | | | |
| `POST` | `/customer/update-profile` | Bearer | 200; errors: - |
| `PUT` | `/customer/cm-firebase-token` | Bearer | 200; errors: - |
| `GET` | `/customer/info` | Bearer | 200; errors: - |
| **Addresses** | | | |
| `POST` | `/customer/address/add` | Bearer | 200; errors: 403 |
| `GET` | `/customer/address/list` | Bearer | 200; errors: - |
| `PUT` | `/customer/address/update/{address_id}` | Bearer | 200; errors: 403, 404 |
| `DELETE` | `/customer/address/delete` | Bearer | 200; errors: 403, 404 |
| **Stores, Categories & Catalog** | | | |
| `GET` | `/zone/list` | none | 200; errors: - |
| `GET` | `/zone/check` | none | 200; errors: - |
| `GET` | `/module` | none | 200; errors: - |
| `GET` | `/categories` | none | 200; errors: - |
| `GET` | `/stores/get-stores/all` | none | 200; errors: - |
| `GET` | `/stores/details/{store_id}` | none | 200; errors: - |
| `GET` | `/stores/search` | none | 200; errors: - |
| `GET` | `/items/search` | none | 200; errors: - |
| `GET` | `/items/latest` | none | 200; errors: - |
| `GET` | `/items/details/{item_id}` | none | 200; errors: - |
| **Cart & Checkout** | | | |
| `POST` | `/customer/cart/add` | Bearer | 200; errors: - |
| `POST` | `/customer/cart/update` | Bearer | 200; errors: 404 |
| `DELETE` | `/customer/cart/remove-item` | Bearer | -; errors: 404 |
| `GET` | `/customer/cart/list` | Bearer | 200; errors: - |
| `POST` | `/customer/order/place` | Bearer | 200; errors: 403, 404 |
| **Orders & Order Details** | | | |
| `GET` | `/customer/order/running-orders` | Bearer | 200; errors: - |
| `GET` | `/customer/order/list` | Bearer | 200; errors: - |
| `GET` | `/customer/order/details` | Bearer | 200; errors: - |
| `GET` | `/customer/order/track` | Bearer | 200; errors: - |
| `GET` | `/customer/order/cancellation-reasons` | Bearer | 200; errors: - |
| `PUT` | `/customer/order/cancel` | Bearer | 200; errors: - |
| **Live Tracking & Delivery OTP** | | | |
| `GET` | `/customer/orders/{order_id}/tracking` | Bearer | 200; errors: - |
| `POST` | `/customer/orders/{order_id}/delivery-otp/request` | Bearer | 200; errors: 409 |
| **Notifications** | | | |
| `GET` | `/customer/notifications` | Bearer | 200; errors: 422 |
| `GET` | `/customer/notifications/unread-count` | Bearer | 200; errors: - |
| `PATCH` | `/customer/notifications/{notification_id}/read` | Bearer | 200; errors: - |
| `POST` | `/customer/notifications/read-all` | Bearer | 200; errors: - |
| **Delivery Subscriptions** | | | |
| `GET` | `/customer/subscription-plans` | none | 200; errors: - |
| `POST` | `/customer/subscriptions/purchase-intent` | Bearer | 201; errors: 404 |
| `GET` | `/customer/subscriptions/current` | Bearer | 200; errors: - |
| `GET` | `/customer/subscriptions/history` | Bearer | 200; errors: - |
| `GET` | `/customer/subscriptions/{subscription_id}` | Bearer | 200; errors: - |
| `GET` | `/customer/subscriptions/{subscription_id}/usage` | Bearer | 200; errors: - |
| **Loyalty** | | | |
| `GET` | `/customer/loyalty` | Bearer | 200; errors: - |
| `GET` | `/customer/loyalty/history` | Bearer | 200; errors: - |
| `GET` | `/customer/loyalty/rewards` | Bearer | 200; errors: - |
| `GET` | `/customer/loyalty/rewards/999999/usage` | Bearer | -; errors: 404 |
| **Parcels** | | | |
| `GET` | `/customer/parcels` | Bearer | 200; errors: - |
| `GET` | `/customer/parcels/{parcel_id}` | Bearer | 200; errors: - |
| `GET` | `/customer/parcels/{parcel_cod_id}` | Bearer | 200; errors: - |
| `POST` | `/customer/parcels/{parcel_id}/location` | Bearer | 200; errors: 422 |
| **Pharmacy Requests** | | | |
| `POST` | `/customer/pharmacy-requests` | Bearer | 201; errors: 422 |
| `GET` | `/customer/pharmacy-requests` | Bearer | 200; errors: - |
| `GET` | `/customer/pharmacy-requests/{pharmacy_request_id}` | Bearer | 200; errors: - |
| `GET` | `/customer/pharmacy-requests/{pharmacy_request_id}/prescription` | Bearer | 200; errors: - |
| **Payments (gated)** | | | |
| `POST` | `/customer/payments/verify` | Bearer | -; errors: 422 |
| `POST` | `/customer/payments/initiate` | Bearer | -; errors: 422 |
| **Security Tests** | | | |
| `GET` | `/customer/info` | none | -; errors: 401 |
| `PUT` | `/customer/order/cancel` | Bearer | -; errors: 403, 404 |
| `POST` | `/customer/address/add` | none | -; errors: 401 |
| `GET` | `/customer/order/details` | Bearer | -; errors: 404 |
| `GET` | `/customer/order/track` | Bearer | -; errors: 404 |
| `GET` | `/customer/orders/{order_id}/tracking` | Bearer | -; errors: 404 |
| `POST` | `/customer/orders/{order_id}/delivery-otp/request` | Bearer | -; errors: 404 |
| `PATCH` | `/customer/notifications/{notification_id}/read` | Bearer | -; errors: 404 |
| `GET` | `/customer/parcels/{parcel_id}` | Bearer | -; errors: 404 |
| `POST` | `/customer/parcels/{parcel_id}/location` | Bearer | -; errors: 404 |
| `GET` | `/customer/pharmacy-requests/{pharmacy_request_id}` | Bearer | -; errors: 404 |
| `GET` | `/customer/pharmacy-requests/{pharmacy_request_id}/prescription` | Bearer | -; errors: 404 |
| `POST` | `/customer/payments/initiate` | Bearer | -; errors: 403 |
| `GET` | `/customer/order/running-orders` | Bearer | 200; errors: - |

## 11. Security guarantees (all tested)

Invalid/missing token (401); another customer's order (details, track, tracking, delivery OTP, cancel), notification, parcel, pharmacy request and prescription all return 404 (403 for cancel, "Not found"); payment initiation for someone else's order returns 403. See folder `90 Security Tests`.
