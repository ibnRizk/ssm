# SSM Customer API

For the engineer building the **Customer (user) app**. This file is self-contained: you do not need the Merchant or Driver documents.

| File | What it is |
|---|---|
| `SSM_CUSTOMER_API.postman_collection.json` | 132 ready-to-run requests in 18 folders |
| `SSM_PRODUCTION.postman_environment.json` | production server (`https://ssm.husseintech.com/api/v1`), empty credentials |
| `SSM_LOCAL.postman_environment.json` | local Laravel (`php artisan serve`) with the fixture accounts |

**How to run it:** import the collection and one environment, then run the folders in order. `01 Auth` registers two fresh customers (A and B) and saves their tokens; every later request reads its IDs and tokens from the environment automatically. Folder `01b` is opt-in because it sends a real SMS. Folder `98` deletes customer B on purpose and therefore runs last.

**Status of this collection:** last regenerated 2026-10-02. Every request was validated against the production route table (same path, same HTTP verb, same authentication: 0 mismatches). Requests marked *opt-in* are skipped unless you set the variable named in their folder.

## 1. Conventions

| Item | Value |
|---|---|
| Base URL | `https://ssm.husseintech.com/api/v1` (production) |
| Format | JSON in and out. Always send `Accept: application/json`. Multipart only for the pharmacy prescription upload. |
| Language | `X-localization: ar` or `en`. Notification titles and most messages are translated server-side. |
| Zone headers | Catalog, cart and order calls need `zoneId: [8]` (a JSON array with the customer's zone id) and `moduleId: 1`. Active production zones: **7 = Mansoura, 8 = Cairo**. |
| Auth | `Authorization: Bearer <token>` (Laravel Passport token, valid about one year) |
| Idempotency | `POST /customer/order/place` accepts `Idempotency-Key` (see 4.4). |

### Authentication (Passport; different from the Merchant and Driver apps)

- `POST /auth/sign-up` `{ name, phone, email, password }` returns `{ token }`; the customer is signed in. `name` is one field ("First Last"); `phone` and `email` must be unique; password at least 8 characters.
- `POST /auth/login` `{ login_type: "manual", email_or_phone, field_type: "phone" | "email", password }` returns `{ token }`.
- Wrong credentials: **401** `auth-001`. Missing fields, duplicate phone/e-mail: **403** with `errors[]` (legacy convention).
- There is **no logout route**: call `POST /customer/remove-fcm-token` (stops pushes to this device) and then delete the token locally. `GET /customer/info` is the "is my token still valid?" check (401 when not).
- Auth routes are throttled (about 10 per minute per IP, **429**).
- **Forgot password:** `POST /auth/forgot-password` `{ verification_method: "phone", phone }` sends an OTP -> `POST /auth/verify-token` `{ verification_method, phone, reset_token }` -> `PUT /auth/reset-password` `{ verification_method, phone, reset_token, password, confirm_password }`.
- **Delete account** (store requirement): `DELETE /customer/remove-account`. Refused while the customer has an ongoing order (HTTP **203**, code `on-going`); otherwise the token is revoked and the account removed.

### Error shapes

| Situation | Status | Body |
|---|---|---|
| Not signed in / bad token | 401 | `{"message":"Unauthenticated."}` |
| Legacy validation (auth, cart, order, address) | 403 | `{"errors":[{"code":"field","message":"..."}]}` |
| SSM validation and business rules | 422 | `{"message":"...","errors":[{"code":"...","message":"..."}]}` or Laravel `errors: { field: [...] }` |
| Not found or not yours | 404 | `{"message":"..."}` / `errors[]` |
| Business refusals in `order/place` | 203 or 403 | `{"errors":[{"code":"order_amount", ...}]}` |
| Idempotency conflict | 409 | `idempotency_conflict` / `order_in_progress` |
| Too many requests | 429 | Laravel throttle body |

Branch on the HTTP status and `errors[].code`, never on the wording of `message`. Resources that belong to someone else always answer as if they did not exist (404).

## 2. App start and home screen

1. `GET /config/customer` (no token) on every app start: `support { phone, email }`, `legal { terms, privacy }`, `application { name, currency, timezone, maintenance_mode, minimum_versions { android, ios }, store_urls }`. Show a **force-update** screen when the installed version is below `minimum_versions`, and a maintenance screen when `maintenance_mode` is true.
2. **Home slider:** `GET /stores/featured-promotions?limit=10&page=1` with the `zoneId` header. Each item: `store_id`, `store_path` (open the store screen with it), `store`, `mobile_banner_url`, `desktop_banner_url`, optional `video_url`. Only active promotions of active, featured stores **in the customer's zone** are returned, so a customer in Cairo never sees a Mansoura banner. Missing `zoneId` -> **403** `zoneId`.
3. Other home data: `GET /banners?zone_id=8` (the legacy `zoneId` header also works), `GET /categories`, `GET /stores/get-stores/all`, `GET /stores/pharmacies`.

## 3. Addresses and zone

`POST /customer/address/add` (`address_type`, `contact_person_name`, `contact_person_number`, `address`, `latitude`, `longitude`) returns `address_id` and `zone_ids`. Coordinates outside every zone: **403** `coordinates`. `GET /customer/address/list`, `PUT /customer/address/update/{id}`, `DELETE /customer/address/delete?address_id=` (404 for foreign ids).

**The zone decides what the customer sees.** Use the zone of the selected delivery address in the `zoneId` header. If the customer moves (for example from Cairo to Mansoura) they must add/select an address in the new zone; otherwise they keep seeing the old zone's stores and banners.

## 4. Ordering

### 4.1 Browse
`GET /stores/get-stores/all`, `GET /stores/details/{id}`, `GET /stores/search?name=`, `GET /items/latest?category_id=0&store_id=`, `GET /items/search?name=`, `GET /items/details/{id}` (all public).

### 4.2 Favourite stores
`POST /customer/favorite-stores/{store}` (201, adding twice is safe), `GET /customer/favorite-stores` -> `{ data: [stores], total }`, `DELETE /customer/favorite-stores/{store}`. Unknown store: 404.

### 4.3 Cart and checkout total
- Cart: `POST /customer/cart/add` `{ item_id, model: "Item", quantity, price }`, `POST /customer/cart/update` `{ cart_id, quantity }`, `DELETE /customer/cart/remove-item`, `GET /customer/cart/list`. The cart lives on the server.
- **Checkout total:** `POST /customer/order/quote` `{ store_id, order_type: "delivery" | "take_away", distance, coupon_code? }`. This is the authoritative breakdown: `subtotal`, `tax`, `discounts { coupon, delivery }`, `original_delivery_charge`, `delivery_charge`, `free_delivery_applied`, `free_delivery_source` (`coupon` | `subscription` | `loyalty` | null), `total`, `currency`. **Show this total; do not compute it in the app.** Errors: `cart_empty`, `store_closed`, `coupon_invalid` (422).
- Coupon check: `POST /customer/coupon/apply` `{ code, store_id }` -> 200 with the coupon, 404 not found, 406 usage limit, 407 expired, 403 not eligible.

### 4.4 Place the order (with Idempotency-Key)
`POST /customer/order/place` `{ order_type: "delivery", payment_method: "cash_on_delivery", store_id, order_amount, distance, address, latitude, longitude, contact_person_name, contact_person_number }`. The server rebuilds the order from the cart and recomputes every amount (`order_amount` is required by validation but not trusted). Response `{ message, order_id, total_ammount, status: "pending", created_at, user_id }` (`total_ammount` is the real spelling).

Send `Idempotency-Key: <uuid>` (one new key per checkout attempt). If the network drops, **retry with the same key and the same body**: the server returns the first answer with header `Idempotent-Replay: true` and does not create a second order. Same key with a different body -> **409** `idempotency_conflict`; first request still running -> **409** `order_in_progress`.

Only `cash_on_delivery` is enabled. COD above the zone maximum is refused (HTTP 203, `order_amount`).

### 4.5 Orders, invoice, cancel, review
- `GET /customer/orders?per_page=20&status=` (Laravel pagination) and `GET /customer/orders/{id}` (order + `details` + `store` + `payments` + `invoice { subtotal, tax, delivery_charge, coupon_discount, total }`). These expose the canonical `ssm_status`; prefer them for new screens.
- Legacy endpoints still work: `GET /customer/order/running-orders`, `/order/list`, `/order/details?order_id=`, `/order/track?order_id=`.
- Cancel: `PUT /customer/order/cancel` `{ order_id, reason }` only while the order is still `pending` (before the merchant accepts); afterwards **403**. Retrying a successful cancel is safe.
- Review: `POST /customer/orders/{id}/review` `{ store_rating: 1-5, driver_rating?: 1-5, comment? }`, only after delivery (otherwise **422** `order_not_delivered`). Sending it again updates the review. The merchant sees and answers reviews in the merchant app.

### 4.6 Order status (driven by the merchant and the driver)
`pending_merchant` -> `accepted` -> `preparing` -> `ready_for_pickup` -> `dispatching` -> `driver_assigned` -> `driver_accepted` -> `picked_up` -> `out_for_delivery` -> `delivered`. Other ends: `rejected` (merchant), `cancelled`, `assignment_failed` (no driver accepted; the merchant can retry dispatch). `ssm_status` is authoritative; the legacy `order_status` is kept for backward compatibility only.

## 5. Live tracking and delivery OTP

`GET /customer/orders/{order}/tracking` -> `{ order_id, ssm_status, tracking_allowed, driver, location, pickup, server_now }`. While `ssm_status` is `driver_accepted`, `picked_up` or `out_for_delivery`, `driver { id, name }` and `location { latitude, longitude, accuracy, heading, speed, server_received_at, is_fresh }` are filled; in every other state (also after delivery) they are `null`.

`POST /customer/orders/{order}/delivery-otp/request` (only while `out_for_delivery`, 5 per minute) -> `{ delivery_otp: { challenge_id, otp, expires_at } }`. Show the 6-digit code; the customer tells it to the driver. Otherwise **409** `otp-not-available`. The legacy `otp` field inside order payloads is **not** the delivery OTP.

## 6. Pharmacy requests (prescriptions)

1. `POST /customer/pharmacy-requests` (**multipart**: `pharmacy_store_id`, `request_text`, `recipient_name`, `recipient_phone`, `delivery_address`, `latitude`, `longitude`, `prescription` image up to 10 MB). Text or image is required. **201** with the request (`status: submitted`) and a price `warning`.
2. The pharmacy sends a quote: the request becomes `quoted` with `medicine_amount`, `medicine_summary`, `pharmacy_note`. Show it from `GET /customer/pharmacy-requests` / `GET /customer/pharmacy-requests/{id}`.
3. The customer decides:
   - `POST /customer/pharmacy-requests/{id}/accept-quote` -> creates the priced **COD order**: `{ status: "converted", order_id, total }`. Continue with the normal order screens.
   - `POST /customer/pharmacy-requests/{id}/reject-quote` `{ reason? }` -> `status: rejected`.
   - Not quoted (yet) or already decided -> **422** `pharmacy_quote_not_actionable`.
4. The prescription image is private: responses only contain `has_prescription` and `attachment_meta { filename, mime_type, size_bytes }`; download it with `GET /customer/pharmacy-requests/{id}/prescription` and your bearer token.

> Some pharmacies still use the older one-step flow (the pharmacy prices and creates the order directly). In that case the request goes straight to `converted` with an `order_id`; the app only has to show it.

## 7. Notifications and push

- Inbox: `GET /customer/notifications?per_page=20&status=all|read|unread` (per_page 1-50), `GET /customer/notifications/unread-count`, `PATCH /customer/notifications/{id}/read`, `POST /customer/notifications/read-all`. Items: `{ id, type, title, body, entity { type, id }, is_read, read_at, created_at, occurred_at }`, already translated.
- FCM token: `PUT /customer/cm-firebase-token` `{ cm_firebase_token }` after login; `POST /customer/remove-fcm-token` on logout. One device per customer.
- FCM messages are **data-only and minimal** (`notification_id`, `type`, `entity_type`, `entity_id`, `unread_count`): after a push, read the inbox / the order from REST.
- Realtime (WebSocket, Pusher protocol): authenticate with `POST /broadcasting/auth` using the same bearer token, subscribe to `private-customer.{customer_id}` (and `private-order.{order_id}`). Events: `.ssm.order.status_changed` (ignore any with a lower `status_version` than you have), `.ssm.driver.assigned`, `.ssm.driver.location_updated`, `.ssm.notification.created`. Realtime only says "something changed"; REST is the source of truth, so always refetch after reconnecting.

## 8. Delivery subscriptions and loyalty

- Plans: `GET /customer/subscription-plans?zone_id=` (public). `POST /customer/subscriptions/purchase-intent` `{ plan_id }` creates an **unpaid pending** subscription (201); an admin activates it after payment. `GET /customer/subscriptions/current` (`deliveries_total`, `deliveries_used`, `deliveries_remaining`, `expires_at` or `data: null`), `/history`, `/{id}`, `/{id}/usage`.
- Loyalty: `GET /customer/loyalty` -> `{ eligible_orders_required, current_progress, orders_remaining_for_next_reward, available_free_deliveries, lifetime_* }`; every delivered order adds one. `/loyalty/history`, `/loyalty/rewards`. Ignore the legacy `loyalty_point` / wallet fields in `customer/info`.
- Both benefits are applied automatically by `order/quote` and `order/place` (`free_delivery_source`).

## 9. Parcels

Admin-created warehouse parcels delivered by an SSM driver: `GET /customer/parcels`, `GET /customer/parcels/{id}`, `POST /customer/parcels/{id}/location` `{ latitude, longitude, delivery_address, notes }` (not after delivery). Customer delivery fee is always `0.00`. `payment_type` is `PREPAID` or `COD` (`cod_amount`).

## 10. Payments

Online payment is **not enabled**: `POST /customer/payments/initiate` returns **422** `payment-gateway-unavailable` for every gateway. Do not build a payment UI yet. (`POST /payments/webhook/{gateway}` is server-to-server and not for the app.)

## 11. Security guarantees (folder `90 Security Tests`)

Missing/invalid token -> 401. Another customer's order (details, track, tracking, invoice, OTP, cancel), cart line, address, notification, parcel, pharmacy request and prescription are never reachable (404, or 403 for cancel). Payment initiation for someone else's order -> 403.

---

## Endpoint reference

Generated from the collection. **Auth** `token` = the app's own bearer token, `none` = public; another variable name means a second test account. **Expect** = the HTTP status(es) the request asserts. Request bodies are listed under each table.

### 00 App config & home

Public, no token. Call `GET /config/customer` on app start (support, legal links, currency, timezone, maintenance mode and minimum app versions for a force-update screen).

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 1 | Customer app config | `GET /config/customer` | none | 200 |
| 2 | Home banners (zone_id query) | `GET /banners?zone_id={{zone_id}}` | none | 200 |
| 3 | Featured store banners & videos (Arabic) | `GET /stores/featured-promotions?limit=10&page=1` | none | 200 |
| 4 | Featured store banners without zoneId (validation) | `GET /stores/featured-promotions` | none | 403 |

<details><summary>Notes, headers and bodies</summary>

**2. Home banners (zone_id query)**

`zone_id` query parameter is accepted; the legacy `zoneId: [id]` header still works.

**3. Featured store banners & videos (Arabic)**

Home slider of featured stores in the customer zone(s) (`zoneId` header, JSON array). Each promotion has `store_id`, `store_path` (in-app route), `store`, `mobile_banner_url`, `desktop_banner_url` and an optional `video_url`. Only active promotions of active, featured stores are returned. `limit` is 1-50.

</details>

### 01 Auth

Passport bearer token. `POST /auth/sign-up` and `POST /auth/login` both return `{ token }`. Business validation errors on the legacy auth controllers use HTTP 403; wrong credentials use 401. Auth routes are throttled (10 per minute per IP, HTTP 429).

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 5 | Register customer A | `POST /auth/sign-up` | none | 200 |
| 6 | Register with a duplicate phone | `POST /auth/sign-up` | none | 403 |
| 7 | Login (manual, phone) | `POST /auth/login` | none | 200 |
| 8 | Login with a wrong password | `POST /auth/login` | none | 401 |
| 9 | Login with a missing password | `POST /auth/login` | none | 403 |
| 10 | Register customer B (used by Security Tests) | `POST /auth/sign-up` | none | 200 |
| 11 | Session check (profile) | `GET /customer/info` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**5. Register customer A**

Creates a customer and returns a Passport access token. Phone and email must be unique.

```json
{
  "name": "Sara Customer",
  "phone": "{{customer_phone}}",
  "email": "{{customer_email}}",
  "password": "{{customer_password}}"
}
```

**6. Register with a duplicate phone**

```json
{
  "name": "Duplicate",
  "phone": "{{customer_phone}}",
  "email": "dup.{{customer_email}}",
  "password": "{{customer_password}}"
}
```

**7. Login (manual, phone)**

```json
{
  "login_type": "manual",
  "email_or_phone": "{{customer_phone}}",
  "field_type": "phone",
  "password": "{{customer_password}}"
}
```

**8. Login with a wrong password**

```json
{
  "login_type": "manual",
  "email_or_phone": "{{customer_phone}}",
  "field_type": "phone",
  "password": "WrongPass#1"
}
```

**9. Login with a missing password**

```json
{
  "login_type": "manual",
  "email_or_phone": "{{customer_phone}}",
  "field_type": "phone"
}
```

**10. Register customer B (used by Security Tests)**

```json
{
  "name": "Omar Customer",
  "phone": "{{customer_b_phone}}",
  "email": "{{customer_b_email}}",
  "password": "{{customer_b_password}}"
}
```

**11. Session check (profile)**

Customers have no dedicated session-validate route; `GET /customer/info` is the session check and returns the profile.

</details>

### 01b Password recovery (manual opt-in)

Skipped unless `run_customer_password_recovery` is set because it sends a real SMS/e-mail. Flow: forgot-password -> OTP arrives -> set `customer_reset_token` -> verify-token -> reset-password. `verification_method` is `phone` or `email`.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 12 | Request password reset OTP *(opt-in: `run_customer_password_recovery`)* | `POST /auth/forgot-password` | none | 200 |
| 13 | Verify password reset OTP | `POST /auth/verify-token` | none | 200 |
| 14 | Reset password | `PUT /auth/reset-password` | none | 200 |

<details><summary>Notes, headers and bodies</summary>

**12. Request password reset OTP**

```json
{
  "verification_method": "phone",
  "phone": "{{customer_phone}}"
}
```

**13. Verify password reset OTP**

```json
{
  "verification_method": "phone",
  "phone": "{{customer_phone}}",
  "reset_token": "{{customer_reset_token}}"
}
```

**14. Reset password**

```json
{
  "verification_method": "phone",
  "phone": "{{customer_phone}}",
  "reset_token": "{{customer_reset_token}}",
  "password": "{{customer_password}}",
  "confirm_password": "{{customer_password}}"
}
```

</details>

### 02 Profile

Profile read/update and push token registration.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 15 | Update profile | `POST /customer/update-profile` | token | 200 |
| 16 | Update profile with duplicate customer B email | `POST /customer/update-profile` | token | 403 |
| 17 | Register FCM token | `PUT /customer/cm-firebase-token` | token | 200 |
| 18 | Profile does not echo the FCM token back as auth data | `GET /customer/info` | token | 200 |
| 19 | Remove FCM token (call on logout) | `POST /customer/remove-fcm-token` | token | 200 |
| 20 | Register FCM token again | `PUT /customer/cm-firebase-token` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**15. Update profile**

Body uses `name` (first and last name in one field), `email`, `phone`.

```json
{
  "name": "Sara Customer",
  "email": "{{customer_email}}",
  "phone": "{{customer_phone}}"
}
```

**16. Update profile with duplicate customer B email**

```json
{
  "name": "Sara Customer",
  "email": "{{customer_b_email}}",
  "phone": "{{customer_phone}}"
}
```

**17. Register FCM token**

```json
{
  "cm_firebase_token": "postman-fcm-token-not-a-real-token"
}
```

**19. Remove FCM token (call on logout)**

Stops push notifications to this device. The app must call it on logout (there is no separate customer logout route; drop the bearer token locally afterwards).

**20. Register FCM token again**

```json
{
  "cm_firebase_token": "postman-fcm-token-not-a-real-token"
}
```

</details>

### 03 Addresses

Saved delivery addresses. Coordinates must fall inside a service zone (otherwise HTTP 403, code `coordinates`).

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 21 | Add address | `POST /customer/address/add` | token | 200 |
| 22 | List addresses | `GET /customer/address/list` | token | 200 |
| 23 | Update address | `PUT /customer/address/update/{{address_id}}` | token | 200 |
| 24 | Security: customer B cannot update customer A address | `PUT /customer/address/update/{{address_id}}` | `customer_b_token` | 404 |
| 25 | Update unknown address | `PUT /customer/address/update/999999` | token | 404 |
| 26 | Add address outside every zone | `POST /customer/address/add` | token | 403 |
| 27 | Add temporary address | `POST /customer/address/add` | token | 200 |
| 28 | Find temporary address id | `GET /customer/address/list` | token | 200 |
| 29 | Delete temporary address | `DELETE /customer/address/delete?address_id={{address_tmp_id}}` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**21. Add address**

```json
{
  "address_type": "home",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}",
  "address": "Olaya St 12, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800"
}
```

**23. Update address**

```json
{
  "address_type": "home",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}",
  "address": "Olaya St 12, Building 4, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800"
}
```

**24. Security: customer B cannot update customer A address**

```json
{
  "address_type": "home",
  "contact_person_name": "Attacker",
  "contact_person_number": "{{customer_b_phone}}",
  "address": "Foreign overwrite",
  "latitude": "24.7100",
  "longitude": "46.6800"
}
```

**25. Update unknown address**

```json
{
  "address_type": "home",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}",
  "address": "Unknown",
  "latitude": "24.7100",
  "longitude": "46.6800"
}
```

**26. Add address outside every zone**

```json
{
  "address_type": "other",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}",
  "address": "Jeddah",
  "latitude": "21.5400",
  "longitude": "39.1700"
}
```

**27. Add temporary address**

```json
{
  "address_type": "other",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}",
  "address": "Temporary address",
  "latitude": "24.7200",
  "longitude": "46.6900"
}
```

</details>

### 04 Stores, Categories & Catalog

Public catalog reads (no token needed). Send `zoneId` (JSON array) and `moduleId` headers.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 30 | Zones | `GET /zone/list` | none | 200 |
| 31 | Zone check for coordinates | `GET /zone/check?lat=24.71&lng=46.68&zone_id={{zone_id}}` | none | 200 |
| 32 | Modules | `GET /module` | none | 200 |
| 33 | Store categories | `GET /categories` | none | 200 |
| 34 | Stores in selected category | `GET /categories/stores/{{store_category_id}}?offset=1&limit=10` | none | 200 |
| 35 | Pharmacies | `GET /stores/pharmacies?offset=1&limit=50` | none | 200 |
| 36 | All stores in zone | `GET /stores/get-stores/all?offset=1&limit=10` | none | 200 |
| 37 | Store details | `GET /stores/details/{{store_id}}` | none | 200 |
| 38 | Search stores | `GET /stores/search?name=Store&offset=1&limit=10` | none | 200 |
| 39 | Search items | `GET /items/search?name=Item&offset=1&limit=10` | none | 200 |
| 40 | Products of selected store | `GET /items/latest?category_id=0&store_id={{store_id}}&offset=1&limit=50&type=all` | none | 200 |
| 41 | Item details | `GET /items/details/{{item_id}}` | none | 200 |

<details><summary>Notes, headers and bodies</summary>

**33. Store categories**

Regular SSM store types. Pharmacy is intentionally separate and is loaded from `GET /stores/pharmacies`.

**34. Stores in selected category**

Returns stores whose `ssm_store_category_id` matches the category selected from `GET /categories`.

**35. Pharmacies**

Dedicated pharmacy list. Pharmacies are excluded from the regular categories and all-stores responses.

**36. All stores in zone**

Regular stores only; pharmacies are excluded. Use `GET /stores/pharmacies` for the pharmacy flow.

**40. Products of selected store**

Returns the products belonging to the store selected by Stores in selected category.

</details>

### 05 Cart & Checkout

The cart is stored server-side; `POST /customer/order/place` turns the caller's cart into an Order. The Order starts in legacy status `pending` (canonical `pending_merchant` once the Merchant reads it). Rule violations from the legacy order controller can return HTTP 203 or 403 with an `errors` array.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 42 | Add item to cart | `POST /customer/cart/add` | token | 200 |
| 43 | Update cart quantity | `POST /customer/cart/update` | token | 200 |
| 44 | Security: another customer cannot update this cart line | `POST /customer/cart/update` | `customer_b_token` | 404 |
| 45 | Security: another customer cannot remove this cart line | `DELETE /customer/cart/remove-item` | `customer_b_token` | 404 |
| 46 | Update an unknown cart line | `POST /customer/cart/update` | token | 404 |
| 47 | List cart | `GET /customer/cart/list` | token | 200 |
| 48 | Quote order total (before placing) | `POST /customer/order/quote` | token | 200 |
| 49 | Quote with an invalid coupon | `POST /customer/order/quote` | token | 422 |
| 50 | Quote for a store with an empty cart | `POST /customer/order/quote` | token | 404 / 422 |
| 51 | Apply coupon (unknown code) | `POST /customer/coupon/apply` | token | 404 |
| 52 | Place order without an address (validation) | `POST /customer/order/place` | token | 403 |
| 53 | Place order outside the service zone | `POST /customer/order/place` | token | 403 / 404 |
| 54 | Place order (cash on delivery) | `POST /customer/order/place` | token | 200 |
| 55 | Retry the same checkout (idempotent replay) | `POST /customer/order/place` | token | 200 |
| 56 | Same key with a different body (conflict) | `POST /customer/order/place` | token | 409 |
| 57 | Add item to cart (second order) | `POST /customer/cart/add` | token | 200 |
| 58 | Place second order (for the reject scenario) | `POST /customer/order/place` | token | 200 |
| 59 | Add item to cart (third order) | `POST /customer/cart/add` | token | 200 |
| 60 | Place third order (for the cancel scenario) | `POST /customer/order/place` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**42. Add item to cart**

```json
{
  "item_id": "{{item_id}}",
  "model": "Item",
  "quantity": 1,
  "price": 10
}
```

**43. Update cart quantity**

```json
{
  "cart_id": "{{cart_id}}",
  "quantity": 2
}
```

**44. Security: another customer cannot update this cart line**

```json
{
  "cart_id": "{{cart_id}}",
  "quantity": 99
}
```

**45. Security: another customer cannot remove this cart line**

```json
{
  "cart_id": "{{cart_id}}"
}
```

**46. Update an unknown cart line**

```json
{
  "cart_id": 999999,
  "quantity": 1
}
```

**48. Quote order total (before placing)**

Authoritative price breakdown for the checkout screen, calculated from the caller's server-side cart for one store: `subtotal`, `tax`, `discounts.coupon`, `discounts.delivery`, `original_delivery_charge`, `delivery_charge`, `free_delivery_applied`, `free_delivery_source` (coupon | subscription | loyalty | null) and `total`. Body: `store_id`, `order_type` (delivery | take_away), `distance` (km, required for delivery), optional `coupon_code`. Show this total to the customer instead of calculating it in the app.

```json
{
  "store_id": "{{store_id}}",
  "order_type": "delivery",
  "distance": 3
}
```

**49. Quote with an invalid coupon**

```json
{
  "store_id": "{{store_id}}",
  "order_type": "delivery",
  "distance": 3,
  "coupon_code": "NOT-A-COUPON"
}
```

**50. Quote for a store with an empty cart**

```json
{
  "store_id": 999999,
  "order_type": "take_away"
}
```

**51. Apply coupon (unknown code)**

Body: `code`, `store_id`. 200 returns the coupon; 404 not found; 406 usage limit reached; 407 expired; 403 not eligible. `GET /coupon/apply?code=&store_id=` is the legacy alias.

```json
{
  "code": "NOT-A-COUPON",
  "store_id": "{{store_id}}"
}
```

**52. Place order without an address (validation)**

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 20
}
```

**53. Place order outside the service zone**

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 20,
  "distance": 3,
  "address": "Jeddah",
  "latitude": "21.5400",
  "longitude": "39.1700",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}"
}
```

**54. Place order (cash on delivery)**

Creates the Order from the current cart. Saves `order_id` for the Merchant and Driver collections. Send an `Idempotency-Key` header (1-255 chars, one per checkout attempt): if the response is lost, retry with the SAME key and body and the server replays the first answer (`Idempotent-Replay: true`) instead of creating a second order.

Headers: `Idempotency-Key: {{checkout_key}}`

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 20,
  "distance": 3,
  "address": "Olaya St 12, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}"
}
```

**55. Retry the same checkout (idempotent replay)**

Headers: `Idempotency-Key: {{checkout_key}}`

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 20,
  "distance": 3,
  "address": "Olaya St 12, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}"
}
```

**56. Same key with a different body (conflict)**

Headers: `Idempotency-Key: {{checkout_key}}`

```json
{
  "order_type": "take_away",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 1
}
```

**57. Add item to cart (second order)**

A second order is placed so the Merchant collection can demonstrate a rejection.

```json
{
  "item_id": "{{item_id}}",
  "model": "Item",
  "quantity": 1,
  "price": 10
}
```

**58. Place second order (for the reject scenario)**

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 10,
  "distance": 3,
  "address": "Olaya St 12, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}"
}
```

**59. Add item to cart (third order)**

A third order is placed to demonstrate customer cancellation.

```json
{
  "item_id": "{{item_id}}",
  "model": "Item",
  "quantity": 1,
  "price": 10
}
```

**60. Place third order (for the cancel scenario)**

```json
{
  "order_type": "delivery",
  "payment_method": "cash_on_delivery",
  "store_id": "{{store_id}}",
  "order_amount": 10,
  "distance": 3,
  "address": "Olaya St 12, Riyadh",
  "latitude": "24.7100",
  "longitude": "46.6800",
  "contact_person_name": "Sara Customer",
  "contact_person_number": "{{customer_phone}}"
}
```

</details>

### 06 Orders & Order Details

Order lists and detail for the authenticated customer.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 61 | Running orders | `GET /customer/order/running-orders?offset=1&limit=10` | token | 200 |
| 62 | Order history | `GET /customer/order/list?offset=1&limit=10` | token | 200 |
| 63 | Order details (line items) | `GET /customer/order/details?order_id={{order_id}}` | token | 200 |
| 64 | Track order (legacy summary) | `GET /customer/order/track?order_id={{order_id}}` | token | 200 |
| 65 | Orders (SSM, paginated) | `GET /customer/orders?per_page=10` | token | 200 |
| 66 | Orders with an invalid page size (validation) | `GET /customer/orders?per_page=500` | token | 422 |
| 67 | Order invoice (SSM detail) | `GET /customer/orders/{{order_id}}` | token | 200 |
| 68 | Order invoice of another customer | `GET /customer/orders/{{order_id}}` | `customer_b_token` | 404 |
| 69 | Review an order that is not delivered yet | `POST /customer/orders/{{order_id}}/review` | token | 422 |
| 70 | Review with an invalid rating (validation) | `POST /customer/orders/{{order_id}}/review` | token | 422 |
| 71 | Cancellation reasons | `GET /customer/order/cancellation-reasons?offset=1&limit=10&user_type=customer` | token | 200 |
| 72 | Cancel a pending order | `PUT /customer/order/cancel` | token | 200 |
| 73 | Cancel the same order again (idempotent retry) | `PUT /customer/order/cancel` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**65. Orders (SSM, paginated)**

Laravel pagination (`data`, `current_page`, `last_page`, `total`). Each order carries the canonical `ssm_status` and `ssm_status_version` and `details_count`. Optional `status` filter (ssm_status or legacy order_status).

**67. Order invoice (SSM detail)**

Full order with `details`, `store` and `payments`, plus an `invoice` block: `subtotal`, `tax`, `delivery_charge`, `coupon_discount`, `total`.

**69. Review an order that is not delivered yet**

Body: `store_rating` (1-5, required), `driver_rating` (1-5, optional), `comment` (optional). Allowed once per delivered order (a second call updates it). Before delivery it answers `422 order_not_delivered` (what this request checks); the merchant sees reviews in `GET /vendor/reviews`.

```json
{
  "store_rating": 5,
  "driver_rating": 5,
  "comment": "Fast and friendly."
}
```

**70. Review with an invalid rating (validation)**

```json
{
  "store_rating": 9
}
```

**72. Cancel a pending order**

Customers can cancel only while the Order is still `pending` (before the Merchant accepts). Legacy behaviour: the order is marked canceled without a canonical SSM history entry.

```json
{
  "order_id": "{{order_cancel_id}}",
  "reason": "Changed my mind"
}
```

**73. Cancel the same order again (idempotent retry)**

A retry after a lost response is safe: it answers the same success and does not restore stock or bump counters a second time.

```json
{
  "order_id": "{{order_cancel_id}}",
  "reason": "Again"
}
```

</details>

### 06b Favorite stores

Customer favourites (`ssm_customer_favorite_stores`). Adding twice is safe.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 74 | Add store to favorites | `POST /customer/favorite-stores/{{store_id}}` | token | 201 |
| 75 | Add the same store again (safe) | `POST /customer/favorite-stores/{{store_id}}` | token | 201 |
| 76 | List favorite stores | `GET /customer/favorite-stores` | token | 200 |
| 77 | Add an unknown store | `POST /customer/favorite-stores/999999` | token | 404 |
| 78 | Remove store from favorites | `DELETE /customer/favorite-stores/{{store_id}}` | token | 200 |

### 07 Live Tracking & Delivery OTP

SSM REST tracking. The response is state-aware: while the canonical status is `driver_accepted`, `picked_up` or `out_for_delivery` the assigned Driver and latest location are returned; in every other state (including after delivery) `driver` and `location` are `null`.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 79 | Order tracking | `GET /customer/orders/{{order_id}}/tracking` | token | 200 |
| 80 | Request delivery OTP | `POST /customer/orders/{{order_id}}/delivery-otp/request` | token | 200 / 409 |

<details><summary>Notes, headers and bodies</summary>

**80. Request delivery OTP**

Available only while the Order is out for delivery (HTTP 200 with `delivery_otp`); otherwise HTTP 409 `otp-not-available`. The customer shows the code to the Driver. Throttled 5/min.

</details>

### 08 Notifications

In-app inbox (`ssm_notifications`). Pagination uses Laravel resource pagination (`data`, `links`, `meta`); `per_page` 1-50, `status` all|read|unread.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 81 | List notifications | `GET /customer/notifications?per_page=20&status=all` | token | 200 |
| 82 | List notifications (page size 1) | `GET /customer/notifications?per_page=1` | token | 200 |
| 83 | List notifications (invalid per_page) | `GET /customer/notifications?per_page=500` | token | 422 |
| 84 | Unread count | `GET /customer/notifications/unread-count` | token | 200 |
| 85 | Mark one notification read | `PATCH /customer/notifications/{{notification_id}}/read` | token | 200 |
| 86 | Mark all notifications read | `POST /customer/notifications/read-all` | token | 200 |
| 87 | Unread count after read-all | `GET /customer/notifications/unread-count` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**85. Mark one notification read**

Skipped automatically when the inbox is still empty.

</details>

### 09 Delivery Subscriptions

Zone-based delivery-count plans. `purchase-intent` only records an unpaid PENDING subscription (online payment is not integrated); activation is an admin action. An active subscription appears in `current`.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 88 | List plans | `GET /customer/subscription-plans?zone_id={{zone_id}}` | none | 200 |
| 89 | Create purchase intent | `POST /customer/subscriptions/purchase-intent` | token | 201 |
| 90 | Purchase intent for an unknown plan | `POST /customer/subscriptions/purchase-intent` | token | 404 |
| 91 | Current (active) subscription | `GET /customer/subscriptions/current` | token | 200 |
| 92 | Subscription history | `GET /customer/subscriptions/history` | token | 200 |
| 93 | Subscription details | `GET /customer/subscriptions/{{subscription_id}}` | token | 200 |
| 94 | Subscription usage | `GET /customer/subscriptions/{{subscription_id}}/usage` | token | 200 |

<details><summary>Notes, headers and bodies</summary>

**89. Create purchase intent**

```json
{
  "plan_id": "{{plan_id}}"
}
```

**90. Purchase intent for an unknown plan**

```json
{
  "plan_id": 999999
}
```

</details>

### 10 Loyalty

SSM loyalty (order-count based free deliveries). Independent from the legacy `users.loyalty_point` column.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 95 | Loyalty summary | `GET /customer/loyalty` | token | 200 |
| 96 | Loyalty history | `GET /customer/loyalty/history` | token | 200 |
| 97 | Available rewards | `GET /customer/loyalty/rewards` | token | 200 |
| 98 | Reward usage (unknown reward) | `GET /customer/loyalty/rewards/999999/usage` | token | 404 |

### 11 Parcels

Warehouse parcels created by admins and delivered by SSM Drivers. Customer delivery fee is always 0.00 SAR. Parcels are matched to the customer by `customer_id` or recipient phone.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 99 | List parcels | `GET /customer/parcels` | token | 200 |
| 100 | Parcel details (prepaid) | `GET /customer/parcels/{{parcel_id}}` | token | 200 |
| 101 | Parcel details (cash on delivery) | `GET /customer/parcels/{{parcel_cod_id}}` | token | 200 |
| 102 | Update parcel drop-off location | `POST /customer/parcels/{{parcel_id}}/location` | token | 200 |
| 103 | Update parcel location with an invalid latitude | `POST /customer/parcels/{{parcel_id}}/location` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**102. Update parcel drop-off location**

```json
{
  "latitude": 24.705,
  "longitude": 46.69,
  "delivery_address": "Al Malaz, Riyadh (gate 2)",
  "notes": "Call on arrival"
}
```

**103. Update parcel location with an invalid latitude**

```json
{
  "latitude": 123
}
```

</details>

### 12 Pharmacy Requests

Prescription/text requests sent to a pharmacy store. Prescriptions are stored on a private disk and only streamed by `GET .../prescription` to the owning customer (or the pharmacy store's Merchant). The stored path is never returned.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 104 | Create pharmacy request (with prescription) | `POST /customer/pharmacy-requests` | token | 201 |
| 105 | Create pharmacy request without content (validation) | `POST /customer/pharmacy-requests` | token | 422 |
| 106 | Create pharmacy request for a non-pharmacy store | `POST /customer/pharmacy-requests` | token | 422 |
| 107 | List pharmacy requests | `GET /customer/pharmacy-requests` | token | 200 |
| 108 | Pharmacy request details | `GET /customer/pharmacy-requests/{{pharmacy_request_id}}` | token | 200 |
| 109 | Download own prescription (private stream) | `GET /customer/pharmacy-requests/{{pharmacy_request_id}}/prescription` | token | 200 |
| 110 | Accept the pharmacy quote (creates the COD order) | `POST /customer/pharmacy-requests/{{pharmacy_request_id}}/accept-quote` | token | 200 / 422 |
| 111 | Reject a pharmacy quote (unknown request) | `POST /customer/pharmacy-requests/999999/reject-quote` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**104. Create pharmacy request (with prescription)**

```text
pharmacy_store_id = {{store_id}}
request_text = Please quote for the attached prescription.
recipient_name = Sara Customer
recipient_phone = {{customer_phone}}
delivery_address = Olaya St 12, Riyadh
latitude = 24.71
longitude = 46.68
prescription = <file>
```

**105. Create pharmacy request without content (validation)**

```text
pharmacy_store_id = {{store_id}}
```

**106. Create pharmacy request for a non-pharmacy store**

```text
pharmacy_store_id = 999999
request_text = x
```

**110. Accept the pharmacy quote (creates the COD order)**

Quote lifecycle: `submitted` -> pharmacy sends a quote (`quoted`, with `medicine_amount`, `medicine_summary`, `pharmacy_note`) -> the customer accepts (creates the priced COD order, status `converted`, returns `order_id` and `total`) or rejects. Run the Merchant collection request "Send a price quote to the customer" first to get 200 here; otherwise the request is not quoted yet and the answer is `422 pharmacy_quote_not_actionable`.

**111. Reject a pharmacy quote (unknown request)**

Body: optional `reason`. Allowed only while the request is `quoted`; the request becomes `rejected`.

```json
{
  "reason": "Too expensive"
}
```

</details>

### 13 Payments (gated)

Online payment is not enabled for SSM yet: every gateway is disabled by default. These requests document the guard rails only; do not build a payment UI against them yet.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 112 | Verify an unknown payment transaction (validation) | `POST /customer/payments/verify` | token | 422 |
| 113 | Initiate payment with an unsupported gateway (validation) | `POST /customer/payments/initiate` | token | 422 |
| 114 | Initiate payment for a disabled gateway | `POST /customer/payments/initiate` | token | 422 |

<details><summary>Notes, headers and bodies</summary>

**112. Verify an unknown payment transaction (validation)**

```json
{
  "transaction_id": 999999
}
```

**113. Initiate payment with an unsupported gateway (validation)**

```json
{
  "order_id": "{{order_id}}",
  "gateway": "unknown"
}
```

**114. Initiate payment for a disabled gateway**

```json
{
  "order_id": "{{order_id}}",
  "gateway": "stripe"
}
```

</details>

### 90 Security Tests

Negative tests. Customer B (registered in `01 Auth`) must never reach Customer A's resources.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 115 | Invalid token | `GET /customer/info` | invalid token | 401 |
| 116 | No token | `GET /customer/info` | none | 401 |
| 117 | Cancel an order after the merchant accepted it | `PUT /customer/order/cancel` | token | 403 |
| 118 | Foreign order cancel | `PUT /customer/order/cancel` | `customer_b_token` | 403 / 404 |
| 119 | Malformed bearer on a protected write | `POST /customer/address/add` | invalid token | 401 |
| 120 | Foreign order details | `GET /customer/order/details?order_id={{order_id}}` | `customer_b_token` | 404 |
| 121 | Foreign order track | `GET /customer/order/track?order_id={{order_id}}` | `customer_b_token` | 404 |
| 122 | Foreign order live tracking | `GET /customer/orders/{{order_id}}/tracking` | `customer_b_token` | 404 |
| 123 | Foreign order delivery OTP | `POST /customer/orders/{{order_id}}/delivery-otp/request` | `customer_b_token` | 404 |
| 124 | Foreign notification | `PATCH /customer/notifications/{{notification_id}}/read` | `customer_b_token` | 404 |
| 125 | Foreign parcel | `GET /customer/parcels/{{parcel_id}}` | `customer_b_token` | 404 |
| 126 | Foreign parcel location update | `POST /customer/parcels/{{parcel_id}}/location` | `customer_b_token` | 404 |
| 127 | Foreign pharmacy request | `GET /customer/pharmacy-requests/{{pharmacy_request_id}}` | `customer_b_token` | 404 |
| 128 | Foreign prescription download | `GET /customer/pharmacy-requests/{{pharmacy_request_id}}/prescription` | `customer_b_token` | 404 |
| 129 | Payment initiation for a foreign order | `POST /customer/payments/initiate` | `customer_b_token` | 403 |
| 130 | Customer B sees no foreign orders in its history | `GET /customer/order/running-orders?offset=1&limit=10` | `customer_b_token` | 200 |

<details><summary>Notes, headers and bodies</summary>

**117. Cancel an order after the merchant accepted it**

Runs only once the main order has moved past `pending` (the Order tracking request records its status); the customer cancel is then refused.

```json
{
  "order_id": "{{order_id}}",
  "reason": "Too late"
}
```

**118. Foreign order cancel**

```json
{
  "order_id": "{{order_id}}",
  "reason": "Not mine"
}
```

**119. Malformed bearer on a protected write**

```json
{
  "address": "x"
}
```

**126. Foreign parcel location update**

```json
{
  "latitude": 24.7,
  "longitude": 46.7
}
```

**129. Payment initiation for a foreign order**

```json
{
  "order_id": "{{order_id}}",
  "gateway": "stripe"
}
```

</details>

### 98 Account deletion (customer B)

Runs last and uses customer B so customer A stays usable. Deletion is refused while the customer has an ongoing order (HTTP 203 with code `on-going`, legacy behaviour); otherwise the token is revoked and the account is removed.

| # | Request | Method & path | Auth | Expect |
|---|---|---|---|---|
| 131 | Delete account | `DELETE /customer/remove-account` | `customer_b_token` | 200 / 203 |
| 132 | Token no longer works after deletion | `GET /customer/info` | `customer_b_token` | 200 / 401 |

<details><summary>Notes, headers and bodies</summary>

**132. Token no longer works after deletion**

401 once the account was deleted (200 only if the deletion above was refused).

</details>
