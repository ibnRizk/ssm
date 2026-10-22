# SSM Parcels — Mobile API Update

Date: 2026-10-20  
API base URL: `https://api.ssm-sa.com/api/v1`

This document covers the two separate parcel products in SSM. They must not be mixed in the mobile applications.

| Product | Who creates it | Driver API prefix | Meaning |
| --- | --- | --- | --- |
| Customer-to-customer (C2C) | A customer sends to another customer | `/delivery-man/c2c-parcels` | Home-to-home delivery |
| Admin / warehouse parcel | Admin registers a shipment received from a shipping company | `/delivery-man/parcels` | Warehouse last-mile delivery |

All protected endpoints require the appropriate Bearer token. Driver mutation requests also need a fresh `Idempotency-Key` UUID.

---

## 1. C2C customer parcel creation

### Quote the price

```http
POST /customer/c2c-parcels/quote
Authorization: Bearer {customer_token}
Content-Type: application/json
```

```json
{
  "sender_latitude": 30.05,
  "sender_longitude": 31.24,
  "recipient_latitude": 30.04,
  "recipient_longitude": 31.23,
  "category": "medium",
  "weight_kg": 2,
  "is_fragile": false
}
```

The response contains the server-calculated price, `quote_token`, distance, and `currency: "SAR"`. The mobile app must display the returned amount; it must not calculate the total itself.

### Create the C2C parcel

```http
POST /customer/c2c-parcels
Authorization: Bearer {customer_token}
Idempotency-Key: {new_uuid}
Content-Type: multipart/form-data
```

Required fields include sender/recipient details, both coordinates, parcel data, `prohibited_items_acknowledged=true`, and one to five parcel images.

Important phone behavior:

- `recipient_phone` accepts local or international mobile formatting, such as `05XXXXXXXX`, `9665XXXXXXXX`, or `+9665XXXXXXXX`.
- Arabic and Persian digits are accepted, for example `٠٥٠...`.
- If `sender_phone` is empty or omitted, the backend uses the logged-in customer's registered phone number.
- When the recipient already has a verified account, the parcel is automatically linked to that account. The sender does not need a recipient user ID.

Example contact fields:

```json
{
  "sender_name": "Sender name",
  "sender_phone": "0500000001",
  "sender_address": "Pickup address",
  "recipient_name": "Recipient name",
  "recipient_phone": "٠٥٠٠٠٠٠٠٠٢",
  "recipient_address": "Drop-off address"
}
```

---

## 2. C2C driver offers and rejection

### List current offers

```http
GET /delivery-man/c2c-parcels/offers
Authorization: Bearer {driver_token}
```

Each offer contains `offer_id` and `parcel_id`. Before accepting, it includes only coarse coordinates and a safe, readable destination area:

```json
{
  "offer_id": 72,
  "parcel_id": 501,
  "status": "dispatching",
  "pickup_area": { "latitude": 30.05, "longitude": 31.24 },
  "dropoff_area": { "latitude": 30.04, "longitude": 31.23 },
  "destination_area": {
    "id": 10,
    "name": "Ramses",
    "display_name": "رمسيس"
  },
  "total_fee": 25,
  "currency": "SAR"
}
```

`destination_area` is intended for the driver UI before acceptance. It does not disclose the recipient's exact address, name, or phone.

### Reject a C2C offer — preferred endpoint

This follows the same offer-ID pattern as store-order offers.

```http
POST /delivery-man/c2c-parcels/offers/{offer_id}/reject
Authorization: Bearer {driver_token}
Idempotency-Key: {new_uuid}
Content-Type: application/json
```

```json
{
  "reason": "busy"
}
```

Successful response:

```json
{
  "message": "Offer rejected.",
  "data": {
    "offer_id": 72,
    "parcel_id": 501,
    "status": "rejected"
  }
}
```

The backend immediately dispatches the parcel to the next eligible driver. A driver cannot reject another driver's offer.

Compatibility endpoint for older app versions:

```http
POST /delivery-man/c2c-parcels/{parcel_id}/reject
```

### C2C driver lifecycle

```text
dispatching
→ driver_accepted
→ driver_at_pickup
→ picked_up
→ out_for_delivery
→ delivered
```

Relevant endpoints:

```http
POST /delivery-man/c2c-parcels/{parcel_id}/accept
POST /delivery-man/c2c-parcels/{parcel_id}/arrive-pickup
POST /delivery-man/c2c-parcels/{parcel_id}/pickup
POST /delivery-man/c2c-parcels/{parcel_id}/out-for-delivery
POST /delivery-man/c2c-parcels/{parcel_id}/complete
POST /delivery-man/c2c-parcels/{parcel_id}/fail-delivery
POST /delivery-man/c2c-parcels/{parcel_id}/return-to-sender
POST /delivery-man/c2c-parcels/{parcel_id}/return-complete
```

Use `GET /delivery-man/c2c-parcels/current-work` after acceptance for full pickup and delivery data.

---

## 3. Admin / warehouse parcel driver lifecycle

This is not C2C. These parcels are created by the admin after arriving at the warehouse, then assigned to a driver by the admin.

### States

Normal delivery:

```text
ARRIVED_AT_WAREHOUSE
→ OUT_FOR_DELIVERY
→ DELIVERED
```

Failed delivery and warehouse return:

```text
OUT_FOR_DELIVERY
→ FAILED_DELIVERY
→ RETURNED_TO_WAREHOUSE
→ ARRIVED_AT_WAREHOUSE  (after admin assigns a driver again)
```

Meaning of the states:

| State | Meaning | Who acts next |
| --- | --- | --- |
| `ARRIVED_AT_WAREHOUSE` | Stored at warehouse; it may be assigned/reassigned | Admin, then assigned driver |
| `OUT_FOR_DELIVERY` | Driver started the last-mile trip | Driver |
| `FAILED_DELIVERY` | Driver attempted delivery but failed | Same driver: retry or return to warehouse |
| `RETURNED_TO_WAREHOUSE` | Driver returned it; no driver remains assigned | Admin assigns again |
| `DELIVERED` | Terminal state with proof of delivery | No further lifecycle action |

### Driver endpoints

```http
GET  /delivery-man/parcels?status=active
GET  /delivery-man/parcels/{parcel_id}
POST /delivery-man/parcels/{parcel_id}/start-delivery
POST /delivery-man/parcels/{parcel_id}/complete
POST /delivery-man/parcels/{parcel_id}/fail-delivery
POST /delivery-man/parcels/{parcel_id}/return-to-warehouse
```

### Start delivery

```http
POST /delivery-man/parcels/{parcel_id}/start-delivery
Authorization: Bearer {driver_token}
```

This is allowed only for the driver assigned by the admin, when the parcel is `ARRIVED_AT_WAREHOUSE` (or when retrying from `FAILED_DELIVERY`). It returns `OUT_FOR_DELIVERY`.

### Complete delivery

```http
POST /delivery-man/parcels/{parcel_id}/complete
Authorization: Bearer {driver_token}
Content-Type: application/json
```

The backend now strictly accepts completion only from `OUT_FOR_DELIVERY`. A driver cannot skip `start-delivery`, cannot complete a failed parcel, and cannot complete a parcel that returned to the warehouse.

Send one authoritative proof method:

Location/time proof:

```json
{
  "proof_type": "LOCATION_TIME",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "notes": "Handed to recipient"
}
```

OTP proof:

```json
{
  "proof_type": "OTP",
  "otp": "123456"
}
```

For COD parcels, include confirmation of collection:

```json
{
  "proof_type": "LOCATION_TIME",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "cod_collected": true
}
```

### Mark delivery as failed

```http
POST /delivery-man/parcels/{parcel_id}/fail-delivery
Authorization: Bearer {driver_token}
Content-Type: application/json
```

```json
{
  "reason": "recipient_unavailable",
  "notes": "No answer after two calls"
}
```

It is allowed only from `OUT_FOR_DELIVERY` and returns `FAILED_DELIVERY`.

### Return to warehouse

```http
POST /delivery-man/parcels/{parcel_id}/return-to-warehouse
Authorization: Bearer {driver_token}
Content-Type: application/json
```

```json
{
  "notes": "Returning after failed attempt"
}
```

It is allowed only from `FAILED_DELIVERY`. The driver is released and the parcel becomes `RETURNED_TO_WAREHOUSE`; the admin must assign it again.

---

## 4. Currency

The live configuration endpoint returns Saudi Riyal:

```http
GET /config
```

Current response values include:

```json
{
  "currency_symbol": "ر.س.‏",
  "currency_symbol_direction": "left"
}
```

Use the currency returned by each price payload or the configuration endpoint. Do not hard-code USD.

---

## 5. Backend verification completed

- C2C feature suite: 32 passing tests.
- Admin/warehouse parcel lifecycle suite: 7 passing tests.
- Parcel/import suite: 6 passing tests.
- Production database audit found no delivered parcel missing a delivery timestamp or proof, no `OUT_FOR_DELIVERY` parcel without a driver, and no returned warehouse parcel still assigned to a driver.

