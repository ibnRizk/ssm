# Customer Guest Mode API

## What is public

A customer can open the app without logging in and browse zones, stores, pharmacies, products, categories, offers and store details. These endpoints do not need `Authorization`, `guest_id`, or a guest token.

## What needs a guest session

The app must create a guest session before it reads or changes a guest cart, checks out as guest, lists a guest's orders, tracks a guest order, cancels it, or changes its payment method.

`POST /api/v1/auth/guest/request` returns:

```json
{
  "guest_id": 123,
  "guest_token": "returned-once-only",
  "expires_at": "2027-02-08T00:00:00+00:00"
}
```

Store both values securely on the device. Send `guest_id` in the existing request field and send the token in every guest-action request:

```http
X-Guest-Token: <guest_token>
```

The server stores only a SHA-256 hash of the token. A sequential `guest_id` alone is no longer accepted as proof of ownership.

## Login transition

When the user logs in or registers, send the current `guest_id` with the existing login/register request. The backend's existing cart merge keeps the guest cart and makes it the customer's cart. The app should then discard `guest_token` and use the customer bearer token.

## API behavior

| Case | Result |
| --- | --- |
| Browse catalogue without login | `200` |
| Guest cart/order action with a valid `guest_id` + `X-Guest-Token` | Existing response contract, normally `200` |
| Guest action with no token | `401`, `guest_session_required` |
| Wrong or expired token | `401`, `invalid_guest_session` |
| Logged-in customer action | Existing Bearer token behavior; no guest token required |

## Postman

Import [SSM_GUEST_MODE_API.postman_collection.json](SSM_GUEST_MODE_API.postman_collection.json). Run **Create secure guest session** first; it stores `guest_id` and `guest_token` in collection variables automatically.
