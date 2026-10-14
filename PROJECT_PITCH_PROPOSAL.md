# SSM — The Unified Delivery & Logistics Ecosystem
### Project Pitch Proposal · عرض المشروع الاستراتيجي

| | |
|---|---|
| **Prepared for** | Executive stakeholders, enterprise partners and investors |
| **Date** | 14 October 2026 |
| **Scope** | Customer App (`ssm`), Merchant App (`merchant`), Driver App (`ssm_driver`) on one shared backend contract |
| **Basis** | A source-level audit of all three Flutter codebases, their API contracts (`docs/`), and their test suites |

---

## At a Glance

| Metric | Value |
|---|---|
| Native mobile apps (iOS + Android) | **3**, one per side of the marketplace |
| Production Dart source | **1,075 files · ~92,500 lines** |
| Automated test cases authored | **1,812** across 202 test files (Customer 979 · Merchant 477 · Driver 356) |
| Feature modules | **37** (Customer 18 · Merchant 11 · Driver 8) |
| Business verticals already modelled | Restaurants & retail · Pharmacy (prescription → quote) · Door-to-door C2C parcels · Warehouse parcel rounds · Subscriptions & loyalty |
| Shared order status vocabulary | **One canonical lifecycle**, spoken identically by all three apps |
| Real-time channels | Firebase Cloud Messaging in all three apps, plus Pusher WebSocket channels in the Customer and Merchant apps |

---

## 1. Executive Summary & Vision
### الرؤية الاستراتيجية ومنظومة الـ Super App

**SSM is a delivery operating system for a city, not a single delivery app.** One backend and one order lifecycle drive three purpose-built apps: one for the customer who orders or ships, one for the merchant who prepares, and one for the driver who moves the goods. Every handoff between them is checked by the server.

Most players in the region pick one business model:

- **Food and retail aggregators** move goods from a merchant to a customer.
- **Courier companies** move parcels from a warehouse to a door.
- **Peer-to-peer shipping** (one household sending to another) is still mostly WhatsApp, phone calls and cash.

**SSM serves all three on one fleet.** The same driver who carries a restaurant order at lunch can run a warehouse parcel round in the afternoon. The same customer who orders from a pharmacy can send a house-to-house parcel to a relative across town. Every job is tracked, verified and settled through one ledger.

> **The vision:** a city where anything (a meal, a prescription, a parcel, a gift) can move from anyone to anyone, through one trusted network, with a verifiable proof at every handoff.

### Why now

1. **Fleets that serve only one business model are expensive.** Idle drivers between meal peaks cost money. Putting C2C parcels and warehouse rounds on the same fleet raises driver utilisation without adding drivers.
2. **C2C shipping has no trusted digital channel.** SSM's door-to-door flow (quote → dispatch → pickup → delivery code → return-to-sender) turns an informal habit into a product that tracks every step and earns revenue on each parcel.
3. **The platform already exists.** This is not a slide deck about software that might be built. Three apps, 37 feature modules and more than 1,800 automated tests are already in the repositories.

---

## 2. The 3-Pillar Ecosystem Architecture
### تكامل التطبيقات الثلاثة

```
                       ┌──────────────────────────────┐
                       │       SSM Core Backend        │
                       │  Canonical order lifecycle    │
                       │  Dispatch · Pricing · Ledger  │
                       │  Idempotency · Versioning     │
                       └───────┬──────────┬───────────┘
              REST + FCM + WS  │          │  REST + FCM + WS
          ┌────────────────────┘          └────────────────────┐
          ▼                                                    ▼
┌───────────────────┐        ┌───────────────────┐   ┌───────────────────┐
│   Customer App    │        │   Merchant App    │   │    Driver App     │
│ Order · Ship ·    │        │ Accept · Prepare ·│   │ Offers · Pickup · │
│ Track · Pay · OTP │        │ Ready · Dispatch  │   │ Prove · Collect   │
└───────────────────┘        └───────────────────┘   └───────────────────┘
```

All three apps use the same engineering foundation (described in §3). Because they share one status vocabulary, a status change made by a merchant appears on the customer's screen and on the driver's screen with the same meaning. No app has to translate another app's states.

### 2.1 Customer App · تطبيق العميل

The customer app is a full super-app shell: **18 feature modules** covering restaurants, catalog and cart, checkout, pharmacy, promotions, loyalty, subscriptions, addresses, notifications, order tracking, and the door-to-door parcel product.

**Door-to-door C2C parcel shipping (`c2c_parcels`)**
- **A guided creation flow.** The customer picks pickup and drop-off points on a map, chooses a parcel category, attaches photos, and gets a **server-priced quote with a price breakdown** before committing to anything.
- **A full lifecycle with 16 states**, from `draft` and `quoted` through `dispatching`, `driver_at_pickup`, `picked_up` and `out_for_delivery` to `delivered`. A first-class **return path** (`failed_delivery` → `returning_to_sender` → `returned_to_sender`) means a failed delivery is a managed process, not a lost parcel.
- **Flexible payment.** The shipping fee can be paid in cash by the sender or by the recipient on delivery (`cash_by_sender`, `cash_by_recipient`).
- **Codes tied to each stage.** A delivery code becomes void as soon as the parcel leaves the stage it was issued for, and a separate return code proves the parcel came back to the sender. A code can never be replayed against the wrong stage.
- **Cancellation with rules.** The sender may cancel only before pickup (`isBeforePickup`). Once the driver has the parcel, cancelling is no longer offered.

**Merchant orders and tracking**
- **Server-side quotes before placing an order**, and **idempotent order placement**: one `Idempotency-Key` per attempt, reused on retry, so a weak connection can never create a duplicate order or a double charge.
- **Live tracking** driven by push and real-time events. A delivery OTP is issued when the order goes out for delivery.
- **Tolerant to future backend changes.** An unknown status from a newer backend is treated as "in progress" instead of crashing the app, so the backend can add states without forcing an app update.

**Privacy and trust**
- Tokens are kept in OS-encrypted secure storage (`flutter_secure_storage`).
- In-app account deletion is available, as both app stores require.
- Release builds are signed with a dedicated release keystore.

### 2.2 Merchant App · تطبيق التاجر

The merchant app turns a store into a node in the dispatch network. It defines **about 40 vendor API endpoints** across 11 feature modules.

- **Accepting orders and running the kitchen.** Accept and reject (with typed reasons), *start preparing*, and *ready for pickup*. Readiness is the trigger that **starts driver dispatch automatically**.
- **Safe concurrent commands.** Every order command carries an `expected_version` (optimistic locking) and an `Idempotency-Key`. If two staff members tap at the same time, or a customer cancels mid-preparation, the result is a clear conflict notice and an automatic reload, never a corrupted order.
- **Recovering from failed dispatch.** If no driver accepts an order (`assignment_failed`), the merchant can **retry dispatch** with one tap.
- **Real-time sync.** FCM push and a Pusher WebSocket channel (`realtime_hub`, authorised through `/broadcasting/auth`) deliver new orders and status changes as they happen, with an in-app notification centre and unread counts.
- **Store operations.** Catalog items with options and availability, working hours, store open/closed status, a dashboard with analytics, a wallet with withdrawal requests, and a **pharmacy workflow**: prescription review, then a priced quote, then an order.
- **Self-service account management.** Registration, onboarding status, forgot and reset password, session validation, and account deletion.

### 2.3 Driver App · تطبيق السائق

The driver app is built for the street: a phone in a bracket, bad signal, and one hand free.

- **Offers sent to the driver.** The server's dispatch engine sends one offer at a time. The driver hears a **ringtone** and sees a countdown driven by the server's `remaining_seconds`, then accepts or rejects. Accepting is idempotent, and a race with another driver is resolved with a clean 409 and a re-read of the offer.
- **Separate workflows for orders and warehouse parcels.** Store orders (`orders` feature: `current-work` → pickup → out-for-delivery → complete) and admin-assigned warehouse parcels (`parcels` feature: `ARRIVED_AT_WAREHOUSE` → `OUT_FOR_DELIVERY` → `DELIVERED`) are **separate domains** with their own entities, repositories, endpoints and screens. A parcel can never be pushed through an order's state machine, and an order can never go through a parcel's.
- **Multi-stop parcel rounds.** A driver can run *"Start parcel tour"* across all active parcels: the app starts the next parcel still at the warehouse until the round is cleared. Parcels are split into **active** and **delivered** lists.
- **Live location.** The app sends heartbeat and location pings to `/delivery-man/heartbeat` and `/delivery-man/location`, and **keeps tracking while in the background**, so a driver who switches to Google Maps stays visible to dispatch and to the customer.
- **Cash-on-delivery enforcement.** Completing a COD order requires `cod_collected` to match the order's payment type. That rule lives in the domain contract, not in the UI. A COD summary endpoint gives the driver a running total of cash in hand.
- **Proof of delivery.** Completion requires a **6-digit customer OTP** (idempotent per code value) or a **location + time proof** where an OTP cannot be used.
- **Problem reporting and handing a job back.** "Report a problem" is available at every step, with translated reason codes, an optional note and an optional photo. A driver can **release** an order before pickup (it goes back to dispatch) or **fail** a delivery after pickup (it goes to support). Both ask the driver to confirm, and both re-read the current work after a refusal so the screen never goes stale.
- **Gated onboarding.** Pending, rejected and approved drivers are routed differently. Operational endpoints are closed to any driver who is not approved.

---

## 3. Core Technical Innovations & Engineering Excellence
### العضلات التقنية

### 3.1 Clean Architecture, applied the same way in all three apps

Every feature in every app follows the same layered structure:

```
Screen ─▶ Cubit (sealed state) ─▶ Repository (abstract, domain)
                                        │
                              RepositoryImpl (data) ─▶ DataSource ─▶ DioConsumer
```

- **Each layer depends only on the layer below it.** The domain layer has **no Flutter imports**, so business rules can be tested with plain Dart.
- **A typed error contract.** The data layer catches transport exceptions and returns `Either<Failure, T>`. No exception ever reaches the UI. Each cubit converts the result into a **Dart 3 sealed state**, and the compiler checks that every case is handled. Loading, empty, error and retry are required states in every screen, not optional extras.
- **No code generation.** No Freezed and no build_runner. Native Dart 3 sealed classes, records and pattern matching keep builds fast and diffs readable.
- **A single dependency-injection root.** Each app wires its dependencies once with `get_it`: cubits are factories, and repositories and data sources are lazy singletons. Any dependency can be replaced with a fake in tests.
- **Proven testability.** **1,812 automated test cases** cover cubits, repositories, data sources, wire-format parsing and widgets. Bug fixes ship with a test that reproduces the bug (for example, *"pin the cancel command's wire format"* and *"re-read current-work after a refused release"*).
- **One playbook across apps.** Customer, Merchant and Driver share the same folder layout, base classes, API consumer, localisation system (Arabic/English, RTL-ready) and design-token theming (light and dark). An engineer who knows one app can work in another from day one.

### 3.2 Security and data privacy

- **Session validation on every launch.** Each app calls its role's `/session/validate` endpoint and listens on an `AuthEventBus`, so a revoked or expired token signs the user out everywhere at once.
- **Separate roles.** Customer, vendor and delivery-man use separate authentication namespaces, token scopes and endpoint prefixes. A driver token cannot call a vendor endpoint. Within each role, the onboarding state (pending, approved, rejected) is enforced on the server (`403`) and reflected in client routing.
- **Encrypted credential storage.** Tokens are kept in the iOS Keychain and in Android's encrypted storage, never in plain preferences.
- **Logs that never leak.** A dedicated `LogRedactor` masks `Authorization` headers, passwords, OTPs and tokens in every network log line before it is printed.
- **Ownership enforced by the server.** A driver can act only on jobs they own (anything else returns `404`). Delivery and return codes are tied to a stage and replaced on every new request.

### 3.3 Real-time sync and resilience

- **Push with FCM in all three apps**, handling foreground, background and opened-from-notification messages. Device tokens are registered and removed against each role's FCM endpoint. In the driver app, a push is treated as a **hint** (`PushHint`) that triggers an authoritative re-read from the server, so a lost or duplicated push can never leave the app in the wrong state.
- **WebSocket channels** (Pusher) in the Customer and Merchant apps carry `order.status_changed` events in real time, with a polling fallback that runs only while the screen is visible and the app is in the foreground.
- **Idempotency throughout.** Every command that changes state (placing an order, merchant commands, accepting an offer, pickup, completion, problem reports, release, fail-delivery) carries an `Idempotency-Key`. Retrying on a weak connection is always safe, and a replay is recognised (`idempotent_replay: true`) rather than applied twice.
- **Optimistic concurrency.** Merchant commands send `expected_version`, and the server rejects stale writes with `409` or `422`. The apps then reload instead of overwriting.
- **Fallbacks when signals fail.** If a push is missed, foreground polling and re-reads on app resume close the gap. If an OTP is not available, location + time proof completes the job. If no driver accepts, the merchant retries dispatch. If a driver cannot finish, release or fail-delivery hands the job back cleanly.

---

## 4. Business Value & Market Disruption
### لماذا هذا المشروع لا يُقدر بثمن؟

### 4.1 Operational efficiency: fewer failed deliveries and fewer disputes

| Lever | Mechanism in the product | Business effect |
|---|---|---|
| **OTP handover** | 6-digit delivery code for orders, and stage-bound delivery and return codes for C2C parcels | Proof that the right person received the goods, which cuts "never arrived" disputes and fraudulent refunds |
| **Location + time proof** | A GPS-stamped completion when an OTP cannot be used | Every delivery leaves an auditable record |
| **Cash control** | `cod_collected` enforced at completion, plus a live COD summary for each driver | Less cash leakage and faster reconciliation |
| **Structured exceptions** | Typed problem reasons, release before pickup, fail-delivery to support, return-to-sender for parcels | Edge cases follow a process instead of turning into calls to support |
| **Idempotency + versioning** | No duplicate orders, no double acceptance, no lost merchant commands | Fewer support tickets and cleaner financial data |

### 4.2 Scalability: built to grow by zone

- **Zones are built into the design.** Driver registration loads zones from `/zone/list`, and customer requests carry zone headers. Opening a new city is a configuration and operations task, not a rebuild.
- **New verticals reuse the core.** Pharmacy and C2C parcels were added as feature modules on the same lifecycle, dispatch and proof infrastructure. The next vertical (groceries, B2B courier, scheduled delivery) follows the same template.
- **Configuration comes from the backend.** Vehicle types, problem reasons, support contacts, store categories and translated display names all come from the server, so operations can change them without an app release.
- **Mobile apps without server state** scale horizontally behind the API. The client keeps no business state that would need migrating.

### 4.3 Cost-effectiveness: one fleet, one platform, many revenue lines

- **A shared fleet across business models.** Restaurant orders, warehouse rounds and C2C parcels all run on the same drivers, which raises utilisation and earnings per driver hour.
- **Dispatch without manual work.** *Ready for pickup* triggers server-side dispatch, offers go to drivers automatically, and failed assignments surface with a one-tap retry. No dispatcher has to watch a phone.
- **One codebase pattern, three apps.** A shared architecture and test discipline lower the cost of each new feature and shorten onboarding for new engineers.
- **Revenue streams already modelled:** delivery fees, C2C shipping fees, customer subscriptions, a loyalty programme, merchant wallets and withdrawals, and pharmacy orders.

---

## 5. Enterprise Hardening Roadmap
### خارطة الطريق نحو الإطلاق المؤسسي

The platform is feature-rich and architecturally mature. These are the remaining steps that take it to full enterprise launch. They are listed openly because a credible partner should know exactly where the work stands.

| # | Track | What remains | Apps |
|---|---|---|---|
| R1 | **Driver-side C2C parcels** | The customer app and the backend contract already support door-to-door parcels end to end. The driver app currently handles store orders and warehouse parcels. A third, isolated C2C workflow (pickup from the sender's door, delivery code, return-to-sender) is the next driver module. | Driver |
| R2 | **Privacy-first contact reveal** | Show recipient and customer phone numbers and exact addresses to the driver only after the offer is accepted, and mask them again when the job ends. This needs a backend contract change plus client gating. | Backend + Driver |
| R3 | **Online prepaid payments** | C2C payment is currently cash by the sender or by the recipient, and merchant orders are COD. Adding a card or wallet payment gateway turns the `pending_payment` state, which already exists, into a live flow. | All |
| R4 | **Unified driver work history** | Today the driver sees active and delivered parcels. The next step is one history view, segmented by job type (orders, warehouse parcels, C2C) with earnings per job. | Backend + Driver |
| R5 | **Store-release compliance** | Release signing keys for the Merchant and Driver Android builds (the Customer app is already done), and in-app account deletion for the Driver app. | Merchant, Driver |
| R6 | **Driver real-time channel** | Add a WebSocket channel to the driver app alongside FCM, matching the Customer and Merchant apps. | Driver |
| R7 | **CI quality gate** | Run the 1,812-test suite and `flutter analyze` on every pull request in CI, and publish coverage. | All |

None of these items require architectural change. Each one is a new module or an extension that fits the existing layers, error contract and lifecycle.

---

## 6. Closing · الخلاصة

SSM brings together three businesses that are usually run separately: merchant delivery, warehouse logistics, and peer-to-peer shipping. It runs them on **one fleet, one lifecycle and one proof-of-delivery standard**. Underneath, it has the engineering foundation that enterprise platforms are judged on: a strict layered architecture, typed failures, idempotent commands, optimistic concurrency, push-driven sync, redacted logs and more than 1,800 automated tests.

The hard part, an architecture that stays correct when networks fail, users double-tap and three apps change the same order at once, **is already built**. What remains is a clear, bounded roadmap.

**SSM is ready for partners who want to own the delivery network of their city.**

---

<sub>Figures in this document come from the source repositories as of 14 October 2026: file and line counts from `lib/`, test-case counts from `test/`, and endpoint and feature inventories from the code and the `docs/` API contracts. The test suites were counted from source, not executed, for this document.</sub>
