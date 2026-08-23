# Escrow ET — Full Project Documentation
### Prepared for Presentation — August 24, 2026

---

## Table of Contents

1. [What Is Escrow ET?](#1-what-is-escrow-et)
2. [The Problem It Solves](#2-the-problem-it-solves)
3. [System Architecture Overview](#3-system-architecture-overview)
4. [Technology Stack](#4-technology-stack)
5. [Backend — Django REST API](#5-backend--django-rest-api)
   - 5.1 [Project Structure](#51-project-structure)
   - 5.2 [Settings & Environment](#52-settings--environment)
   - 5.3 [Custom User Model](#53-custom-user-model)
   - 5.4 [Escrow Contract State Machine](#54-escrow-contract-state-machine)
   - 5.5 [Double-Entry Ledger System](#55-double-entry-ledger-system)
   - 5.6 [Dispute System](#56-dispute-system)
   - 5.7 [Merchant System](#57-merchant-system)
   - 5.8 [Payment Layer — Chapa Integration](#58-payment-layer--chapa-integration)
   - 5.9 [Fayda ID Integration (Backend)](#59-fayda-id-integration-backend)
   - 5.10 [REST API Endpoints](#510-rest-api-endpoints)
   - 5.11 [Database Migrations](#511-database-migrations)
6. [Database — Supabase PostgreSQL](#6-database--supabase-postgresql)
   - 6.1 [Entity-Relationship Diagram](#61-entity-relationship-diagram)
   - 6.2 [All Tables Explained](#62-all-tables-explained)
   - 6.3 [Ledger Integrity Rules](#63-ledger-integrity-rules)
   - 6.4 [Platform System Accounts](#64-platform-system-accounts)
7. [Mobile App — Flutter](#7-mobile-app--flutter)
   - 7.1 [App Entry Point & Initialization](#71-app-entry-point--initialization)
   - 7.2 [State Management with Riverpod](#72-state-management-with-riverpod)
   - 7.3 [Authentication Flow](#73-authentication-flow)
   - 7.4 [Role-Based Shell (Buyer vs Seller)](#74-role-based-shell-buyer-vs-seller)
   - 7.5 [Screens Inventory](#75-screens-inventory)
   - 7.6 [Fayda ID QR Decoder (Dart)](#76-fayda-id-qr-decoder-dart)
   - 7.7 [Data Layer](#77-data-layer)
   - 7.8 [Flutter Dependencies](#78-flutter-dependencies)
8. [Web Portal — React / Vite](#8-web-portal--react--vite)
   - 8.1 [Routing Structure](#81-routing-structure)
   - 8.2 [Page Inventory](#82-page-inventory)
   - 8.3 [Authentication & Protected Routes](#83-authentication--protected-routes)
   - 8.4 [Merchant Dashboard](#84-merchant-dashboard)
   - 8.5 [Admin Panel](#85-admin-panel)
   - 8.6 [Dispute Messaging System](#86-dispute-messaging-system)
9. [Fayda National ID Integration — Deep Dive](#9-fayda-national-id-integration--deep-dive)
10. [Security Architecture](#10-security-architecture)
11. [Design System — Crimson Matrix](#11-design-system--crimson-matrix)
12. [Infrastructure & Deployment](#12-infrastructure--deployment)
13. [Key Technical Decisions & Trade-offs](#13-key-technical-decisions--trade-offs)
14. [Data Flow Walkthroughs](#14-data-flow-walkthroughs)

---

## 1. What Is Escrow ET?

**Escrow ET** is a digital escrow platform built specifically for the Ethiopian market. It is a full-stack, production-grade application that acts as a trusted financial intermediary between buyers and sellers in e-commerce or peer-to-peer transactions.

In a traditional escrow, a neutral third party holds a buyer's money until the seller fulfills the agreed-upon conditions — then the money is released. Escrow ET digitizes this entire process with:

- A **mobile app** (Flutter) used by buyers and sellers in their day-to-day transactions
- A **merchant web portal** (React) used by businesses that want to embed escrow into their checkout flow
- A **REST API** (Django) that powers both clients and handles all financial logic
- A **double-entry ledger** database (Supabase/PostgreSQL) that guarantees financial integrity
- **Chapa** as the Ethiopian payment gateway for funding and releasing funds
- **Fayda** (Ethiopia's national digital ID) as a KYC and authentication method

---

## 2. The Problem It Solves

Ethiopia's digital commerce sector faces a critical trust gap. Buyers are afraid to pay before receiving goods; sellers are afraid to ship before receiving payment. There is no widely available neutral financial escrow service for the Ethiopian market.

Escrow ET solves this by:

- Locking buyer funds in a platform-controlled holding account the moment payment is made
- Releasing funds to the seller only after the buyer cryptographically confirms delivery (via QR code scan or PIN)
- Providing a dispute resolution channel for when things go wrong
- Integrating Ethiopia's Fayda national ID to verify user identity without requiring a separate KYC process
- Offering a merchant API so businesses can build escrow-based checkout into their own platforms

---

## 3. System Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                        CLIENTS                               │
│                                                              │
│   Flutter Mobile App          React Web Portal              │
│   (iOS / Android)             (Merchant + Admin)            │
│   Buyers & Sellers            escrow-et.vercel.app          │
└────────────────┬──────────────────────┬──────────────────────┘
                 │  HTTPS / REST API    │
                 │  Token Auth          │
                 ▼                      ▼
┌────────────────────────────────────────────────────────────┐
│               Django 6.1 REST API                          │
│               (Vercel Serverless / WSGI)                   │
│                                                            │
│   core/views.py — API views                                │
│   core/models.py — ORM + Ledger functions                  │
│   core/chapa.py — Chapa payment wrapper                    │
│   core/fayda.py — Fayda QR decoder + RS256 verifier        │
│   core/notify.py — Merchant webhook dispatch               │
│   core/merchant.py — Merchant key management               │
└────────────────────────┬───────────────────────────────────┘
                         │
                         │ DATABASE_URL (PostgreSQL / SSL)
                         ▼
┌────────────────────────────────────────────────────────────┐
│            Supabase PostgreSQL                             │
│                                                            │
│   10 tables: users, escrow contracts, ledger accounts,    │
│   ledger transactions, ledger entries, disputes,          │
│   dispute messages, payment transactions, payouts,        │
│   merchant settings                                        │
└────────────────────────────────────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────────┐
│            External Services                               │
│                                                            │
│   Chapa (Ethiopian payment gateway)                        │
│   Fayda NIDP (National ID Programme — offline RS256 key)   │
└────────────────────────────────────────────────────────────┘
```

---

## 4. Technology Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| Backend framework | Django | 6.1 | REST API, ORM, admin |
| REST toolkit | Django REST Framework | 3.18.0 | Serializers, views, auth |
| Database | Supabase PostgreSQL | — | Single source of truth |
| DB URL parsing | dj-database-url | 3.0.1 | Parse `DATABASE_URL` |
| DB driver | psycopg[binary] | 3.2.10 | PostgreSQL adapter |
| CORS | django-cors-headers | 4.9.0 | Allow cross-origin requests |
| Static files | whitenoise | 6.9.0 | Serve static files |
| Cryptography | cryptography | 44.0.3 | Fayda RS256 signature |
| HTTP client | requests | 2.34.2 | Chapa API calls |
| Mobile | Flutter (Dart) | SDK ^3.10.0 | iOS + Android app |
| State mgmt | flutter_riverpod | 2.6.1 | Reactive state |
| Local storage | Hive + hive_flutter | 2.2.3 / 1.1.0 | Session persistence |
| QR generation | qr_flutter | 4.1.0 | QR code display |
| QR scanning | mobile_scanner | 7.0.1 | Camera QR reader |
| Image pick | image_picker | 1.1.2 | Gallery / camera |
| Dart crypto | pointycastle | 3.9.1 | Fayda RS256 in Dart |
| Web frontend | React + Vite | — | Merchant portal |
| Web routing | React Router | — | SPA routing |
| Deployment | Vercel | — | Serverless hosting |

---

## 5. Backend — Django REST API

### 5.1 Project Structure

```
backend/
├── manage.py                    # Django CLI entry point
├── requirements.txt             # Python dependencies
├── runtime.txt                  # Python version for Vercel
├── vercel.json                  # Vercel serverless config
├── SCHEMA.md                    # Database schema reference
├── API_DOCS.md                  # API documentation
├── .env.example                 # Environment variable template
├── api/
│   └── index.py                 # Vercel WSGI entrypoint
├── escrow_backend/
│   ├── settings.py              # Django settings
│   ├── urls.py                  # Root URL routing
│   ├── wsgi.py                  # WSGI application
│   └── asgi.py                  # ASGI application
└── core/
    ├── models.py                # All Django models + ledger functions
    ├── views.py                 # All API views
    ├── serializers.py           # DRF serializers
    ├── urls.py                  # URL patterns for core
    ├── chapa.py                 # Chapa payment gateway wrapper
    ├── fayda.py                 # Fayda QR decoder + RS256 verifier
    ├── merchant.py              # Merchant key generation
    ├── notify.py                # Merchant webhook dispatch
    ├── phone.py                 # Phone number normalization
    ├── signals.py               # Django signals
    ├── portal_views.py          # Admin portal views
    ├── admin.py                 # Django admin registration
    └── migrations/
        ├── 0001_initial.py          # All models created
        ├── 0002_schema_harden.py    # Constraints & indexes
        ├── 0003_seed_system_accounts.py  # Platform accounts
        ├── 0004_ledger_immutability.py   # Prevent ledger edits
        ├── 0005_integrity_constraints.py # Check constraints
        └── 0006_user_fayda_identity.py   # Fayda fields added
```

### 5.2 Settings & Environment

Django settings are loaded from environment variables. The application **refuses to start** if critical variables are missing — there is no silent fallback to insecure defaults.

**Required environment variables:**

| Variable | Purpose |
|---|---|
| `DJANGO_SECRET_KEY` | Django cryptographic signing key |
| `DATABASE_URL` | Full Supabase PostgreSQL connection string |
| `CHAPA_SECRET_KEY` | Chapa API authentication key |
| `CHAPA_PUBLIC_KEY` | Chapa public key |
| `CHAPA_WEBHOOK_SECRET` | Secret for HMAC webhook signature verification |
| `DJANGO_DEBUG` | `True` or `False` |
| `DJANGO_ALLOWED_HOSTS` | Comma-separated list of allowed hosts |
| `FRONTEND_URL` | Base URL for redirect links (e.g. after Chapa payment) |
| `ALLOW_SANDBOX_FUND` | Enables sandbox funding for local development |

The settings file also automatically reads `VERCEL_URL` (injected by Vercel at runtime) and adds it to `ALLOWED_HOSTS`. This means no manual configuration change is needed when Vercel generates a new deployment URL.

**Database connection:**
```python
DATABASES = {
    'default': dj_database_url.parse(
        _database_url,
        conn_max_age=0,   # serverless: no persistent connections
        ssl_require=True,
    )
}
```
`conn_max_age=0` is intentional for serverless: Vercel functions are stateless and short-lived, so persistent connections would cause timeouts. `ssl_require=True` enforces encrypted connections to Supabase.

**REST Framework configuration:**
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}
```
Every endpoint requires authentication by default. Views that need to be public (Register, Login, Chapa Webhook) explicitly declare `permission_classes = [AllowAny]`.

---

### 5.3 Custom User Model

The `User` model extends Django's `AbstractUser` and adds Ethiopian-specific fields:

```
core_user
├── id              UUID (primary key, auto-generated)
├── username        CharField (unique — Django default)
├── phone_number    CharField (unique, max 20 chars) — primary contact
├── role            CharField: BUYER | SELLER | MERCHANT | ADMIN
├── kyc_verified    BooleanField (False by default)
├── fayda_number    CharField (unique, null, 10–20 digits) — from Fayda QR
├── legal_name      CharField — from Fayda QR (full name)
├── gender          CharField: M | F — from Fayda QR
├── date_of_birth   DateField — from Fayda QR
└── created_at      DateTimeField (auto)
```

**Why UUID primary key?** UUIDs prevent enumeration attacks (guessing sequential IDs) and are globally unique across distributed systems.

**Why phone_number as unique?** In Ethiopia, phone numbers are the most reliable unique identifier for individuals. Email addresses are far less common.

**Fayda fields:** When a user registers or logs in using their Fayda national ID card, these fields are populated directly from the cryptographically-verified QR payload. This means the platform knows the user's legal identity without them having to type anything — and the identity is verified by a government-issued signature.

---

### 5.4 Escrow Contract State Machine

An `EscrowContract` is the core entity. It has exactly 7 possible states, and the transitions between them are strictly enforced by the API views.

```
PENDING_PAYMENT
      │
      │ Chapa webhook fires (or sandbox-fund in dev)
      ▼
   FUNDED ──────────────────────────────────────────┐
      │                                             │
      │ Seller calls mark-shipped                   │ Either party calls dispute
      ▼                                             │
  IN_TRANSIT ─────────────────────────────────────►│
      │                                        DISPUTED
      │ Buyer confirms delivery (PIN or QR)         │
      ▼                                             │ Admin resolves
  COMPLETED                              CANCELLED or COMPLETED
```

**State rules (enforced in views):**
- Only `SELLER` or `MERCHANT` users can create contracts
- `mark-shipped` is only callable by the seller on a `FUNDED` contract
- `confirm-delivery` is only callable by the buyer on `FUNDED` or `IN_TRANSIT` contracts
- A dispute can only be opened on `FUNDED`, `IN_TRANSIT`, or `DELIVERED_UNVERIFIED` contracts
- Only one dispute per contract (enforced by OneToOneField)

**Database-level constraints** (enforced by PostgreSQL, not just Python):
```python
class Meta:
    constraints = [
        models.CheckConstraint(
            condition=models.Q(amount__gt=0),
            name="escrow_amount_positive",
        ),
        models.CheckConstraint(
            condition=~models.Q(buyer=models.F("seller")),
            name="escrow_buyer_ne_seller",
        ),
    ]
```
These are actual `CHECK` constraints in PostgreSQL — even direct database inserts bypassing Django are rejected.

**Verification PIN:** The `verification_pin` field stores a **hashed** PIN, never plaintext. The code uses Django's built-in password hashing:
```python
def set_verification_pin(self, raw_pin: str) -> None:
    self.verification_pin = make_password(raw_pin)

def check_verification_pin(self, raw_pin: str) -> bool:
    return check_password(raw_pin, self.verification_pin)
```
The API never returns the raw PIN — it only returns `pin_is_set: true/false`. The buyer must know the PIN from an out-of-band channel (told by the seller when handing over the item).

**Delivery QR Token:** Every contract gets a UUID `delivery_qr_token` auto-generated on save. This token is embedded in a QR code shown to the seller. When the buyer scans it, the token is compared server-side to confirm delivery.

---

### 5.5 Double-Entry Ledger System

This is one of the most sophisticated technical aspects of the project. Financial integrity is guaranteed through **double-entry bookkeeping** — the same accounting system used by banks.

**Core principle:** Every financial movement is recorded as two entries — a debit from one account and a credit to another. These must always sum to zero. There is **never a mutable balance column** anywhere in the schema.

**The four tables involved:**

```
LedgerAccount   — represents a "wallet" (user or platform)
    ↓ has many
LedgerTransaction — a posting event (funded, released, refunded)
    ↓ has many
LedgerEntry     — a single debit or credit line
```

**LedgerAccount types:**
| Type | Purpose |
|---|---|
| `USER_WALLET` | One per user, linked by OneToOne |
| `PLATFORM_ESCROW_HOLDING` | Money sitting in escrow |
| `PLATFORM_FEE_REVENUE` | Platform fees collected |
| `PLATFORM_PAYOUT_CLEARING` | Funds being paid out to sellers |

**The three ledger events and their double-entry postings:**

| Event | Debit (money leaves) | Credit (money arrives) | Result |
|---|---|---|---|
| `record_escrow_funded` | Buyer's wallet | HOLDING account | Contract → `FUNDED` |
| `record_escrow_released` | HOLDING account | Seller's wallet | Contract → `COMPLETED` |
| `record_escrow_refunded` | HOLDING account | Buyer's wallet | Contract → `CANCELLED` |

**Example — Buyer pays 850 ETB:**
```
LedgerTransaction (type=ESCROW_FUNDED)
├── LedgerEntry: DEBIT  850.00 ETB from buyer_wallet
└── LedgerEntry: CREDIT 850.00 ETB to platform_escrow_holding
```

After this posting, the buyer's balance (credits minus debits) decreases by 850, and the holding account's balance increases by 850. The total across all accounts remains zero — this is the invariant that makes the system auditable.

**Balance is computed, never stored:**
```python
@property
def balance(self) -> Decimal:
    credits = self.entries.filter(direction='CREDIT').aggregate(total=Sum('amount'))['total'] or 0
    debits = self.entries.filter(direction='DEBIT').aggregate(total=Sum('amount'))['total'] or 0
    return credits - debits
```

**Atomicity guarantee:** All three ledger functions run inside `transaction.atomic()`. This means if any step fails (e.g. the status update after the entries are written), PostgreSQL rolls back everything. There is no such thing as a partial financial state.

**Immutability:** LedgerEntry rows cannot be updated or deleted. Corrections must be posted as new reversing entries. This is enforced by migration `0004_ledger_immutability`.

**Balance verification on every posting:**
```python
def assert_balanced(self) -> None:
    totals = self.entries.aggregate(
        debits=Sum('amount', filter=Q(direction='DEBIT')),
        credits=Sum('amount', filter=Q(direction='CREDIT')),
    )
    if totals['debits'] != totals['credits']:
        raise ValidationError("LedgerTransaction does not balance")
```
This check runs on every new ledger transaction. A posting that doesn't balance raises an exception before it can be committed.

---

### 5.6 Dispute System

The dispute system gives either party (buyer or seller) a mechanism to escalate an issue and pause the fund release.

**Dispute model:**
```
core_dispute
├── id           UUID
├── escrow       OneToOneField → EscrowContract (one dispute per deal)
├── opened_by    ForeignKey → User
├── reason       TextField
├── status       OPEN | UNDER_REVIEW | RESOLVED_REFUNDED | RESOLVED_RELEASED
└── created_at   DateTimeField
```

**DisputeMessage model** (threaded communication):
```
core_disputemessage
├── id              UUID
├── dispute         ForeignKey → Dispute
├── sender          ForeignKey → User
├── message         TextField
├── attachment_url  URLField (optional, for evidence)
└── created_at      DateTimeField
```

When a dispute is opened, the escrow contract status changes to `DISPUTED`. Funds remain locked in the holding account. An admin then reviews the thread, evaluates attachments, and resolves the dispute — either releasing funds to the seller (RESOLVED_RELEASED → `COMPLETED`) or refunding the buyer (RESOLVED_REFUNDED → `CANCELLED`).

---

### 5.7 Merchant System

Merchants are businesses that integrate Escrow ET into their own checkout flow via API.

**MerchantSettings model:**
```
core_merchantsettings
├── id          UUID
├── merchant    OneToOneField → User (must have role=MERCHANT)
├── public_key  CharField (unique, format: pk_live_<hex>)
├── secret_key  CharField (format: sk_live_<hex>)
└── webhook_url URLField (optional)
```

**Key generation** (in `merchant.py`):
```python
def generate_merchant_keys():
    return (
        f"pk_live_{secrets.token_hex(16)}",
        f"sk_live_{secrets.token_hex(24)}",
    )
```
Uses Python's `secrets` module (cryptographically secure random) to generate 32-character hex public keys and 48-character hex secret keys. The generation retries up to 5 times in case of a database collision (astronomically unlikely, but safe).

**Merchant webhooks:** When key escrow events happen (funded, released, disputed), the system pings the merchant's configured webhook URL with a JSON payload:
```json
{
  "event": "escrow.funded",
  "escrow_id": "36f0f955-...",
  "status": "FUNDED",
  "amount": "850.00",
  "currency": "ETB"
}
```
This is a fire-and-forget notification. Failures are logged but never block the main API response.

**Permission check for contract creation:**
```python
def can_create_escrow(user: User) -> bool:
    return user.role in (User.Role.SELLER, User.Role.MERCHANT)
```
Only SELLER and MERCHANT roles can create escrow contracts. BUYER and ADMIN roles cannot.

---

### 5.8 Payment Layer — Chapa Integration

Chapa is Ethiopia's leading payment gateway. The `chapa.py` module wraps the Chapa API into a clean, testable interface.

**Initializing a transaction** (buyer gets redirected to Chapa's hosted checkout):
```python
def initialize_transaction(*, email, amount, currency, tx_ref, ...):
    response = requests.post(
        "https://api.chapa.co/v1/transaction/initialize",
        headers={"Authorization": f"Bearer {settings.CHAPA_SECRET_KEY}"},
        json={"amount": str(amount), "currency": currency, "tx_ref": tx_ref, ...},
        timeout=10,
    )
    return data["data"]["checkout_url"]
```

A unique `tx_ref` is generated for every transaction:
```python
tx_ref = f"escrow-{contract.id}-{uuid.uuid4().hex[:8]}"
```
This format embeds the contract ID for easy lookup and adds 8 random hex characters to prevent collision if the same contract has a payment retried.

**Webhook processing:** When the buyer completes payment on Chapa's hosted page, Chapa sends a webhook to `/api/webhooks/chapa/`. The view:
1. Verifies the HMAC-SHA256 signature in the `Chapa-Signature` header
2. Looks up the `PaymentTransaction` by `tx_ref`
3. If already processed, returns 200 immediately (idempotency)
4. Updates the `PaymentTransaction.status` to `SUCCESS`
5. Calls `record_escrow_funded()` to post the ledger entries atomically
6. Pings the merchant's webhook

**HMAC signature verification:**
```python
def verify_webhook_signature(raw_body: bytes, signature_header: str) -> bool:
    expected = hmac.new(
        settings.CHAPA_WEBHOOK_SECRET.encode(),
        raw_body,
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, signature_header)
```
`hmac.compare_digest` uses constant-time comparison to prevent timing attacks. A timing attack is when an attacker measures response time to guess characters of the secret one byte at a time — constant-time comparison eliminates this vector.

**Sandbox mode:** For local development, when Chapa cannot webhook `localhost`, a special endpoint `/api/escrow/<id>/sandbox-fund/` lets the buyer manually trigger the funding event. This endpoint is disabled in production via `ALLOW_SANDBOX_FUND=False`.

---

### 5.9 Fayda ID Integration (Backend)

The `fayda.py` module is a fully offline Ethiopian national ID QR verifier. It parses the Fayda V4 QR payload and verifies the government's RS256 digital signature — without making any network call to NIDP's servers.

**Why offline?** NIDP does not currently offer a public verification API. The public key used for signing was extracted from the official Fayda scanner at `id.et/scanId`. The key's SPKI SHA-256 fingerprint is `803dcd26...6624a`, which can be independently verified.

**QR Payload structure (Fayda V4):**
```
[face_image_base64]:DLT:[full_name]:[key]:[value]:...:[key]:[value]:SIGN:[JWS_header]..[JWS_signature]
```

Key fields:
- `V` — payload version (must be "4")
- `A` — Fayda Account Number (FAN), 10–20 digits
- `G` — gender (M or F)
- `D` — date of birth (yyyy/mm/dd)

**Verification flow:**
1. Parse the payload structure by finding `:DLT:` and `:SIGN:` markers
2. Extract the JWS (JSON Web Signature) from after `:SIGN:`
3. Decode the JWS header to confirm algorithm is `RS256`
4. Reconstruct the signing input: `[header].[base64url(payload_before_SIGN)]`
5. Verify the signature bytes against the NIDP public key using PKCS#1 v1.5

**FaydaIdentity dataclass (returned on success):**
```python
@dataclass(frozen=True)
class FaydaIdentity:
    full_name: str
    gender: str | None
    fan: str         # Fayda Account Number — used as unique identifier
    date_of_birth: date | None
    payload_version: str
```

**Login with Fayda:** A user can log in by scanning their Fayda card and sending the raw QR payload. The backend verifies the signature, extracts the FAN, and looks up the user:
```python
user = User.objects.get(fayda_number=identity.fan)
```
If found, an auth token is returned. If not, the user is told to sign up first.

---

### 5.10 REST API Endpoints

All endpoints are under the `/api/` prefix.

#### Authentication

| Method | URL | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register/` | None | Register with phone + password |
| POST | `/api/auth/login/` | None | Login with credentials or Fayda QR |
| POST | `/api/auth/logout/` | Token | Invalidate auth token |
| GET | `/api/auth/me/` | Token | Get current user profile |
| PATCH | `/api/auth/me/` | Token | Update profile (username, role) |

#### Escrow Contracts

| Method | URL | Auth | Who | Description |
|---|---|---|---|---|
| POST | `/api/escrow/create/` | Token | Seller/Merchant | Create contract + initiate Chapa payment |
| GET | `/api/escrow/mine/` | Token | Buyer or Seller | List all contracts for current user |
| GET | `/api/escrow/<id>/` | Token | Buyer or Seller | Get single contract |
| POST | `/api/escrow/<id>/pay/` | Token | Buyer | Retry Chapa payment init |
| POST | `/api/escrow/<id>/mark-shipped/` | Token | Seller only | Move FUNDED → IN_TRANSIT |
| POST | `/api/escrow/<id>/confirm-delivery/` | Token | Buyer only | Confirm with PIN or QR token |
| POST | `/api/escrow/<id>/dispute/` | Token | Buyer or Seller | Open dispute |
| POST | `/api/escrow/<id>/sandbox-fund/` | Token | Buyer (dev only) | Simulate Chapa webhook |

#### Webhooks & Merchant

| Method | URL | Auth | Description |
|---|---|---|---|
| POST | `/api/webhooks/chapa/` | HMAC signature | Chapa calls this on payment |

**Request/Response example — Create Escrow:**
```http
POST /api/escrow/create/
Authorization: Token abc123...

{
  "buyer_phone": "0922000001",
  "item_name": "Bluetooth Speaker",
  "amount": "850.00",
  "verification_pin": "9911"
}

HTTP/1.1 201 Created
{
  "id": "36f0f955-3812-4b2d-84b7-72f998e0510c",
  "buyer_phone": "0922000001",
  "seller_phone": "0911000001",
  "item_name": "Bluetooth Speaker",
  "amount": "850.00",
  "currency": "ETB",
  "status": "PENDING_PAYMENT",
  "delivery_qr_token": "cf9dddf3-7e26-4e64-bcd7-079d3557279a",
  "pin_is_set": true,
  "payment_link": "https://checkout.chapa.co/checkout/...",
  "created_at": "2026-08-18T13:40:04.917993+03:00",
  "updated_at": "2026-08-18T13:40:04.934100+03:00"
}
```

**Confirm delivery with PIN:**
```http
POST /api/escrow/36f0f955-3812.../confirm-delivery/
Authorization: Token buyer_token...

{"pin": "9911"}

HTTP/1.1 200 OK
{"id": "...", "status": "COMPLETED", ...}
```

---

### 5.11 Database Migrations

6 migration files document the evolution of the schema:

| Migration | What it does |
|---|---|
| `0001_initial` | Creates all models: User, EscrowContract, Dispute, DisputeMessage, LedgerAccount, LedgerTransaction, LedgerEntry, PaymentTransaction, Payout, MerchantSettings |
| `0002_schema_harden` | Adds database indexes, tightens constraints, adds `delivery_qr_token` |
| `0003_seed_system_accounts` | Data migration — creates the three platform ledger accounts (HOLDING, FEE_REVENUE, PAYOUT_CLEARING) |
| `0004_ledger_immutability` | Adds PostgreSQL rules or triggers to prevent UPDATE/DELETE on `core_ledgerentry` |
| `0005_integrity_constraints` | Adds `CHECK` constraints at the PostgreSQL level for amount positivity and buyer ≠ seller |
| `0006_user_fayda_identity` | Adds `fayda_number`, `legal_name`, `gender`, `date_of_birth` to User |

---

## 6. Database — Supabase PostgreSQL

### 6.1 Entity-Relationship Diagram

```
core_user ──────────────────────── core_ledgeraccount
    │  (1:1 owner)                        │ (entries)
    │                                     │
    │ buyer FK      seller FK     core_ledgerentry
    └──────────────────────────► core_escrowcontract
                                       │
              ┌────────────────────────┼────────────────────────┐
              │                        │                        │
    core_dispute           core_ledgertransaction    core_paymenttransaction
         │                       │ (entries)               │
    core_disputemessage    core_ledgerentry         core_ledgertransaction
                                                    (optional FK)

core_user ──1:1──► core_merchantsettings
core_escrowcontract ──1:1──► core_payout
```

### 6.2 All Tables Explained

**`core_user`** — Every person who uses the platform. One row per user. UUID primary key. Phone number is the unique contact identifier. Fayda fields are populated on KYC verification.

**`core_escrowcontract`** — One row per trade deal. Links buyer and seller, holds the amount, tracks the state machine status, stores the hashed PIN and QR token. The `payment_link` column holds the Chapa checkout URL sent to the buyer.

**`core_dispute`** — Maximum one dispute per escrow contract (enforced by `OneToOneField`). Records the reason and current resolution status.

**`core_disputemessage`** — Threaded messages within a dispute. Allows attachment URLs for evidence (photos of damaged goods, screenshots, etc.)

**`core_merchantsettings`** — One record per merchant user. Stores the `pk_live_*` and `sk_live_*` API keys and an optional webhook URL.

**`core_ledgeraccount`** — A financial account. Either a user wallet (`owner_id` set) or a platform system account (`owner_id` NULL). One wallet per user.

**`core_ledgertransaction`** — The header for a double-entry posting. Identifies the type (FUNDED, RELEASED, REFUNDED), links to the escrow contract, and optionally to the Chapa payment record.

**`core_ledgerentry`** — A single debit or credit line. Every transaction has exactly two entries. Amount is always positive; direction field indicates if it's a debit or credit. Amount column `> 0` enforced by DB constraint.

**`core_paymenttransaction`** — Records every interaction with Chapa. Stores the `tx_ref` (unique Chapa reference), provider, direction, status, and the raw JSON payload from Chapa's webhook.

**`core_payout`** — Created when an escrow is released (`record_escrow_released`). Tracks the seller's payout from `QUEUED` through `PROCESSING` to `SUCCESS`.

### 6.3 Ledger Integrity Rules

1. **Debits = Credits on every transaction.** Verified by `assert_balanced()` before commit.
2. **All amounts > 0.** Enforced by both `MinValueValidator` and PostgreSQL `CHECK` constraint.
3. **One FUNDED, one RELEASED/REFUNDED per escrow.** Enforced by `UniqueConstraint(fields=['escrow_contract', 'transaction_type'])`.
4. **LedgerEntry rows are immutable.** Migration `0004` prevents updates and deletes.
5. **All writes are atomic.** `transaction.atomic()` wraps every ledger function.

### 6.4 Platform System Accounts

Three accounts are seeded by migration `0003` and can never be deleted:

| Account | Role |
|---|---|
| `PLATFORM_ESCROW_HOLDING` | Holds all escrowed funds until delivery is confirmed |
| `PLATFORM_FEE_REVENUE` | Future: receives platform fee cuts |
| `PLATFORM_PAYOUT_CLEARING` | Future: staging account for outbound seller payouts |

These accounts have `owner_id = NULL`. The constraint `uniq_system_ledger_account` prevents duplicate system accounts from being created.

---

## 7. Mobile App — Flutter

The Flutter app is the primary consumer-facing interface. It targets iOS and Android and is written entirely in Dart using Flutter SDK ^3.10.0.

### 7.1 App Entry Point & Initialization

`main.dart` runs before any UI is shown:

1. `WidgetsFlutterBinding.ensureInitialized()` — required for async native calls
2. Android photo picker is configured to use the modern Android Photo Picker API
3. Hive is initialized for local key-value storage
4. `SessionStore` is opened (reads saved auth session from Hive)
5. `ProviderScope` wraps the app with the Riverpod dependency injection tree
6. `sessionStoreProvider` is overridden with the real `SessionStore` instance (dependency injection at the root)

### 7.2 State Management with Riverpod

The app uses `flutter_riverpod` v2 — a compile-safe, reactive state management library.

**Provider hierarchy:**
```
sessionStoreProvider (Provider<SessionStore>)
    └── overridden in main() with real instance

apiClientProvider (Provider<ApiClient>)
    └── creates HTTP client

authApiProvider (Provider<AuthApi>)
    └── depends on apiClientProvider

authControllerProvider (NotifierProvider<AuthController, AuthState>)
    └── reads authApiProvider + sessionStoreProvider

themeControllerProvider (NotifierProvider<ThemeController, bool>)
    └── reads sessionStoreProvider (persists dark/light)

shellTabProvider (StateProvider<int>)
    └── tracks current bottom nav tab

escrowListProvider (...)
    └── fetches escrow contracts from API
```

**Why Riverpod over other options?**
- Compile-time safety — providers are type-checked
- No `BuildContext` required for reads
- `ref.invalidate()` allows cache invalidation (used when app resumes)
- Supports testing by overriding providers

### 7.3 Authentication Flow

`AuthController` is the central state machine for user authentication:

```
App starts → AuthStatus.booting
    ↓ _hydrate() runs
    → Check SessionStore for saved token
    → If token exists: try GET /api/auth/me/ to validate
        → 200: AuthStatus.signedIn
        → 401: clear store → AuthStatus.signedOut
    → If no token: AuthStatus.signedOut
```

The `_BootScreen` shows the brand logo while `AuthStatus.booting`. Once resolved, the app either shows `LoginScreen` or `MainShell`.

**Session persistence:** `Hive` stores the auth token and user object locally. On every app start, the token is re-validated against the server. If the server returns 401 (token expired/revoked), the user is automatically signed out.

### 7.4 Role-Based Shell (Buyer vs Seller)

The `MainShell` widget reads the user's role and renders a completely different navigation structure:

**Seller Shell — 5 tabs:**
1. Dashboard (overview of sales)
2. Payments (create new escrow, payment history)
3. Tracking (shipment status per contract)
4. Alerts (notifications)
5. Settings

**Buyer Shell — 4 tabs:**
1. Home (list of purchases)
2. Scan QR (camera to confirm delivery by scanning QR)
3. Alerts (notifications)
4. Settings

When a user changes their role (via settings), `shellTabProvider` is reset to 0 and the shell rebuilds automatically.

**Tab index protection:** The shell clamps the stored tab index to the valid range for the current role. This prevents out-of-bounds crashes after a role switch:
```dart
final tabCount = isBuyer ? 4 : 5;
final rawIndex = ref.watch(shellTabProvider);
final index = rawIndex.clamp(0, tabCount - 1);
```

**Lifecycle refresh:** The `WidgetsBindingObserver` on `_MainShellState` listens for `AppLifecycleState.resumed`. When the app comes back to the foreground (user returns from Chapa's browser checkout, for example), it calls `ref.invalidate(escrowListProvider)` to refresh the contract list immediately.

### 7.5 Screens Inventory

| Screen | Role | Purpose |
|---|---|---|
| `LoginScreen` | Any | Username/password login, Fayda QR login |
| `RegisterScreen` | Any | Sign up with phone + role selection |
| `FaydaScanScreen` | Any | Camera scan of Fayda ID card |
| `FaydaConfirmScreen` | Any | Show decoded identity before registration |
| `DashboardScreen` | Seller | Overview of active/recent contracts |
| `PaymentsScreen` | Seller | List all contracts + create new |
| `NewPaymentScreen` | Seller | Form to create escrow contract |
| `TrackingListScreen` | Seller | List contracts with shipment status |
| `TrackingDetailScreen` | Seller | Single contract detail + mark shipped |
| `BuyerHomeScreen` | Buyer | List of purchases |
| `BuyerScanTab` | Buyer | QR scanner tab |
| `QrVerifyScreen` | Buyer | After scan — confirm or reject delivery |
| `ScanConfirmScreen` | Buyer | Final confirmation dialog |
| `CheckoutScreen` | Buyer | Pay for an escrow from payment link |
| `PaymentSuccessScreen` | Buyer | Confirmed payment success page |
| `NotificationsScreen` | Both | Alerts and system messages |
| `SettingsScreen` | Both | Profile, role switch, theme, logout |
| `ForgotPasswordScreen` | Any | Password recovery |

### 7.6 Fayda ID QR Decoder (Dart)

The Flutter app contains a full port of the Python Fayda decoder, implemented in `lib/fayda/fayda_decoder.dart`. It uses the `pointycastle` library for RSA cryptography.

**The sealed result type** (Dart 3 exhaustive pattern matching):
```dart
sealed class FaydaResult {}
class FaydaResultOk extends FaydaResult { final FaydaSuccess data; }
class FaydaResultErr extends FaydaResult { final FaydaFailure error; }
```

**Why sealed?** Callers are forced by the compiler to handle both the success and error cases. There is no way to forget error handling — the Dart compiler will show an error if a `switch` expression on a sealed class is not exhaustive.

**RSA public key parsing from PEM in Dart:**
The `_rsaPublicKeyFromPem()` function manually parses the ASN.1 DER encoding of the SPKI-formatted PEM key using `pointycastle`'s ASN1 parser, extracting the RSA modulus and public exponent.

**Signature verification:**
```dart
final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
signer.init(false, PublicKeyParameter<RSAPublicKey>(key));
final ok = signer.verifySignature(
    Uint8List.fromList(utf8.encode(signingInput)),
    RSASignature(signature),
);
```
The OID `0609608648016503040201` identifies SHA-256 in the PKCS#1 DigestInfo structure.

**Face image extraction:** The decoder also supports extracting the face photo embedded in the QR (as WebP bytes in the prefix before `:DLT:`). This can be displayed during registration to let the user confirm their photo matches.

### 7.7 Data Layer

**`ApiClient`** — thin HTTP wrapper over Dart's `http` package:
- Prepends the base API URL
- Attaches `Authorization: Token <token>` header
- Parses JSON responses
- Throws `ApiException` with status code and message on non-2xx responses

**`SessionStore`** — Hive-backed key-value store:
- Stores serialized auth token + user object as JSON
- Stores theme preference (`'dark'` or `'light'`)
- Exposes `read()`, `save()`, `clear()`, and `theme()` methods

**`AuthApi`** — network calls for auth:
- `login()`, `loginWithFayda()`, `register()`, `registerWithFayda()`
- `me()` — validate existing token
- `logout()` — invalidate server-side token
- `updateProfile()` — PATCH profile fields

**`EscrowApi`** — network calls for contracts:
- `mine()`, `getOne()`, `create()`
- `markShipped()`, `confirmDelivery()`
- `openDispute()`, `sandboxFund()`, `pay()`

### 7.8 Flutter Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management |
| `google_fonts` | ^8.0.0 | Geist + Hanken Grotesk fonts |
| `hive` + `hive_flutter` | ^2.2.3 / ^1.1.0 | Local key-value storage |
| `http` | ^1.5.0 | HTTP requests to backend |
| `qr_flutter` | ^4.1.0 | Generate QR codes for delivery tokens |
| `url_launcher` | ^6.3.2 | Open Chapa checkout in browser |
| `mobile_scanner` | ^7.0.1 | Camera-based QR code reader |
| `image_picker` | ^1.1.2 | Pick images from gallery or camera |
| `pointycastle` | ^3.9.1 | RSA/SHA256 crypto for Fayda verification |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 8. Web Portal — React / Vite

The web portal is a separate React SPA aimed at **merchants and admins**. It is deployed to Vercel and served at `escrow-et.vercel.app`.

### 8.1 Routing Structure

Built with React Router. Routes fall into three categories:

**Public routes** (no authentication required):
- `/` — Landing page
- `/login` — Login page
- `/register` — Registration
- `/checkout/:contractId` — Buyer-facing checkout (shared by seller)
- `/payment/:contractId` — Payment page
- `/payment-success` — Post-payment confirmation
- `/qr-code` — QR display
- `/delivery-verified` — Delivery confirmation landing

**Protected merchant routes** (requires auth token):
- `/dashboard` — Merchant overview
- `/transactions` — Transaction history
- `/payment-links` — Create escrow payment links
- `/disputes` — File or view a dispute
- `/disputes/messages` — Dispute messaging thread
- `/settings/developer` — API key management
- `/docs` — Inline developer documentation
- `/profile` — User profile

**Admin-only routes** (requires `role=ADMIN`):
- `/admin` — Admin dashboard
- `/admin/disputes` — All disputes list
- `/admin/disputes/:disputeId` — Dispute detail + resolution controls

### 8.2 Page Inventory

| Page / Component | Purpose |
|---|---|
| `LandingPage` | Marketing homepage with product explanation |
| `LoginPage` | Credential login + Fayda QR import via file upload |
| `RegisterPage` | Sign-up form |
| `MerchantDashboard` | Live stats: active escrows, revenue, dispute count |
| `CreatePaymentLink` | Create escrow contract, get shareable link |
| `TransactionTracking` | Table of all transactions with status filter |
| `Checkout` | Buyer-facing page for a specific escrow contract |
| `Payment` | Direct payment initiation |
| `PaymentSuccess` | Post-Chapa redirect confirmation |
| `QRCodeView` | Display the delivery QR code for seller to show buyer |
| `DeliveryVerified` | Confirmation page after QR delivery verification |
| `DisputeForm` | Form to open a dispute on a contract |
| `DisputeMessages` | Real-time dispute thread with file attachment support |
| `DeveloperSettings` | Show/regenerate API keys and webhook URL |
| `DeveloperDocs` | Inline API documentation |
| `Profile` | Edit user profile |
| `AdminDashboard` | Platform-wide stats for admins |
| `AdminDisputes` | All disputes across all merchants |
| `AdminDisputeDetails` | Full dispute thread + resolution buttons |

### 8.3 Authentication & Protected Routes

`AuthContext.jsx` manages auth state using React Context. On load, it checks for a stored token in `localStorage` and validates it against `/api/auth/me/`.

`ProtectedRoute` uses React Router's `<Outlet>` pattern:
```jsx
// Redirects to /login if not authenticated
const ProtectedRoute = () => {
    const { user } = useContext(AuthContext);
    return user ? <Outlet /> : <Navigate to="/login" />;
};

// Redirects to /dashboard if not admin
const AdminRoute = () => {
    const { user } = useContext(AuthContext);
    return user?.role === 'ADMIN' ? <Outlet /> : <Navigate to="/dashboard" />;
};
```

`FaydaQrInput.jsx` — The web portal also supports Fayda QR login. The user uploads a photo of their Fayda card QR. The `readQrFromFile.js` utility decodes the QR from the image file and sends the raw payload to the login endpoint.

### 8.4 Merchant Dashboard

The `MerchantDashboard` shows:
- Count of active escrow contracts (FUNDED + IN_TRANSIT)
- Total volume processed in ETB
- Count of open disputes
- Recent transactions table
- Quick-create payment link button

### 8.5 Admin Panel

The admin panel is exclusively for `role=ADMIN` users:

`AdminDashboard` — Platform-wide metrics across all merchants.

`AdminDisputes` — A list of all disputes in the system regardless of merchant. Each row shows: dispute ID, escrow ID, amount, status, opened-by, date.

`AdminDisputeDetails` — Shows the full dispute message thread. The admin can:
1. Read all messages from buyer, seller, and previous admins
2. Click "Release Funds" → calls `record_escrow_released()` → seller gets paid
3. Click "Refund Buyer" → calls `record_escrow_refunded()` → buyer gets refunded

### 8.6 Dispute Messaging System

`DisputeMessages.jsx` renders a chat-like thread where:
- Each message shows sender, text, timestamp
- File attachments (evidence photos) are displayed inline
- New messages can be sent with optional file attachment
- Messages are loaded fresh on every render

---

## 9. Fayda National ID Integration — Deep Dive

Fayda is Ethiopia's national digital identity program. Every Ethiopian citizen is issued a smart ID card containing a QR code on the back.

**QR Payload structure (example V4 format):**
```
[base64url_face]:DLT:Full Name:V:4:A:0123456789:G:M:D:1998/03/15:SIGN:eyJhbGciOiJSUzI1NiJ9...[sig]
```

**Breaking this down:**
- `[base64url_face]` — Optional WebP face photo
- `:DLT:` — Delimiter separating face image from identity fields
- `Full Name` — Legal name of the cardholder
- `V:4` — Payload version 4
- `A:0123456789` — Fayda Account Number (FAN)
- `G:M` — Gender (Male)
- `D:1998/03/15` — Date of birth (YYYY/MM/DD)
- `:SIGN:` — Delimiter before the JWS
- `eyJ...` — JWS with detached payload (header..[signature], middle part empty)

**Why detached JWS?** Normally a JWS would be `header.payload.signature`. Fayda uses `header..signature` (detached) where the payload is the QR text itself up to `:SIGN:`. This keeps the QR self-contained — you don't need to base64-encode a copy of the data.

**The verification algorithm:**
```
signing_input = base64url(header) + "." + base64url(payload_before_SIGN)
verify(RSA_public_key, SHA256(signing_input), decoded_signature)
```

**Uses of Fayda in the system:**

| Use case | What happens |
|---|---|
| Register with Fayda | QR decoded client-side or server-side, identity fields auto-filled, `fayda_number` stored |
| Login with Fayda | QR sent to `/auth/login/` with `raw_payload`, backend verifies, looks up by FAN |
| KYC verification | `kyc_verified = True` set when Fayda registration succeeds |

**Security guarantee:** Because the payload is signed by NIDP's RSA private key, no one can forge a Fayda QR. Any tampering with the identity fields invalidates the signature. The platform can trust that the `legal_name`, `gender`, `date_of_birth`, and `fayda_number` came directly from the government-issued card.

---

## 10. Security Architecture

### Authentication
- Token-based auth (DRF `rest_framework.authtoken`)
- Token stored in `Token` table linked to user
- Flutter: token stored in Hive, re-validated on startup
- Web: token stored in `localStorage`, validated on load

### Password Security
- Django's built-in password hashing (PBKDF2 + SHA256)
- Verification PIN also hashed with `make_password()` (same algorithm)
- PINs never appear in API responses

### Webhook Security
- Chapa webhooks verified with HMAC-SHA256
- Constant-time comparison with `hmac.compare_digest()` to prevent timing attacks
- Unknown `tx_ref` values return 404, not 200

### Database Constraints
- `CHECK` constraints at PostgreSQL level (not just ORM)
- `amount > 0` on all financial tables
- `buyer ≠ seller` on EscrowContract
- All ledger amounts must be positive
- Unique constraints on `fayda_number`, `phone_number`, `provider_tx_ref`

### Network Security
- All database connections use `ssl_require=True`
- CORS configured to allow the Flutter app from any IP (necessary for mobile)
- `SECRET_KEY` mandatory at startup — no fallback
- `DEBUG=False` in production

### Idempotency
- Chapa webhook is idempotent — replays of the same `tx_ref` return 200 without re-crediting the ledger
- Unique constraint `uniq_ledger_txn_per_escrow_type` prevents double-posting the same event

### Identity Verification
- Fayda RS256 signature verified offline using pinned NIDP public key
- FAN (Fayda Account Number) stored as unique identifier
- Fake or modified QR payloads are cryptographically rejected

---

## 11. Design System — Crimson Matrix

The app uses a custom design system called **Crimson Matrix** — a dark-first, high-contrast aesthetic inspired by technical precision and modern engineering tools.

### Color Palette

| Role | Dark Mode | Light Mode |
|---|---|---|
| Background | `#131313` | `#F5F5F5` |
| Surface | `#20201F` | `#FFFFFF` |
| Primary accent | `#FFB4AA` / `#E61919` | `#C0000B` |
| On-surface text | `#E5E2E1` | `#1A1A1A` |
| Outline | `#AE8782` | `#5E3F3B` |
| Error | `#FFB4AB` | `#690005` |

The primary red (`#E61919` in dark, `#C0000B` in light) is used **sparingly** — only for critical actions (primary buttons, active states, destructive operations). This keeps the UI calm and purposeful.

### Typography

| Role | Font | Size | Weight |
|---|---|---|---|
| Display heading | Geist | 48px | 700 |
| Large headline | Geist | 32px | 600 |
| Mobile headline | Geist | 24px | 600 |
| Body text | Hanken Grotesk | 16px | 400 |
| Small body | Hanken Grotesk | 14px | 400 |
| Labels / chips | Geist | 12px | 500 |

**Geist** is a developer-centric font designed by Vercel — its geometric precision matches the technical nature of a financial platform.

**Hanken Grotesk** is a humanist sans-serif optimized for body text readability, especially on mobile screens.

### Spacing System

Based on an 8px grid:
- Base unit: 8px
- Container margin: 24px
- Gutter (between columns): 16px
- Section gap: 64px

### Elevation & Depth

Rather than shadows, depth is achieved through **tonal layering**:
- Background: `#0D0D0D`
- Card surface: `#1A1A1A` (+~7% brightness)
- Popover: `#262626` (+~7% more)

Subtle 1px borders at 10% white opacity define card boundaries.

### Shape Language

- Standard components (buttons, inputs, chips): 4px radius
- Large containers (cards, modals): 12px radius
- Pill elements (nav bar active indicator): 9999px radius

### Component Conventions

- **Primary buttons:** Solid red fill, white text
- **Secondary buttons:** 1px red border, transparent fill
- **Input fields:** Dark background with bottom border only (terminal aesthetic); focus state uses red border
- **Status chips:** Background tinted at 10% opacity of status color, solid text
- **Cards:** Flat, no shadows. High-importance cards have a 2px red left-edge accent stripe
- **Status colors:** Red for Active/Alert; gray for Inactive; white for Success (avoids green to maintain brand palette)

### Theming in Flutter

The app supports both light and dark mode via `AppTheme.light()` and `AppTheme.dark()`. The user's preference is stored in Hive via `ThemeController`. The `ThemeMode` is driven by `themeControllerProvider`:

```dart
themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
```

---

## 12. Infrastructure & Deployment

### Backend Deployment — Vercel Serverless

The Django backend is deployed to Vercel as a serverless Python function. `vercel.json` configures the WSGI handler and routes all requests to the Django app:

```
api/index.py → application = get_wsgi_application()
```

**Implications of serverless:**
- `conn_max_age=0` in database settings (no connection pooling)
- No background tasks or Celery (any long-running tasks must be refactored)
- Cold starts are acceptable for this use case

### Database — Supabase

Supabase provides a managed PostgreSQL database with:
- Direct PostgreSQL connection string (port 5432)
- SSL-enforced connections
- Automatic backups
- Built-in Auth (not used here — Django's auth system is used instead)
- Row-level security (not used — Django handles authorization)

### Web Frontend — Vercel

The React app is built with `vite build` and deployed as static files on Vercel. The `web/vercel.json` handles SPA routing (all paths return `index.html` for client-side routing).

### Environment Management

`.env` files are gitignored. `.env.example` files are committed with placeholder values:
```
DJANGO_SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://postgres:password@db.supabase.co:5432/postgres
CHAPA_SECRET_KEY=CHASECK-...
CHAPA_WEBHOOK_SECRET=...
```

---

## 13. Key Technical Decisions & Trade-offs

### Why Django over FastAPI or Node.js?
Django's ORM provides the richest migration system, and `django-admin` gives a free admin interface for database management. For a financial platform where schema integrity is critical, Django's battle-tested ORM and constraint system was the right choice.

### Why double-entry ledger instead of balance columns?
A balance column is a single value that can drift if any bug or race condition occurs. A double-entry ledger provides a complete, immutable audit trail. Every ETB can be traced from source to destination. This is how banks work.

### Why offline Fayda verification instead of an API call?
NIDP doesn't offer a public API. The offline approach (pinned public key) is also more reliable — no network dependency during authentication. The RS256 signature provides the same security guarantee as an online check.

### Why Riverpod over Bloc or Provider?
Riverpod v2 is compile-safe (no runtime errors from missing providers), supports auto-dispose, and doesn't require `BuildContext` for reads. This makes the data layer cleaner and easier to test.

### Why Token auth instead of JWT?
Token auth stores session state in the database. This makes logout immediate and secure — the server can revoke a token at any time. JWT is stateless and cannot be revoked without additional infrastructure. For a financial platform, the ability to instantly invalidate sessions outweighs the scalability benefit of JWTs.

### Why UUID primary keys?
- Non-guessable (prevents enumeration attacks)
- Globally unique (useful for distributed systems)
- Usable as the QR delivery token directly

---

## 14. Data Flow Walkthroughs

### Flow 1: Seller Creates an Escrow and Buyer Pays

```
1. Seller opens "New Payment" screen in Flutter app
2. Enters: buyer's phone, item name, amount (e.g. 850 ETB), 4-digit PIN
3. Flutter calls: POST /api/escrow/create/ with Bearer token

4. Django (EscrowCreateView):
   a. Validates seller role (can_create_escrow)
   b. Looks up buyer by phone number
   c. Hashes the PIN with make_password()
   d. Creates EscrowContract (status=PENDING_PAYMENT)
   e. Auto-generates delivery_qr_token (UUID)
   f. Calls chapa.initialize_transaction() → gets checkout URL
   g. Creates PaymentTransaction (status=INITIATED)
   h. Saves payment_link to EscrowContract
   i. Returns 201 with full contract JSON

5. Flutter shows the payment_link to seller
6. Seller sends the link to buyer (WhatsApp, SMS, etc.)

7. Buyer opens the link → Checkout page (web)
8. Buyer clicks Pay → url_launcher opens Chapa checkout in browser

9. Buyer completes payment on Chapa's hosted page

10. Chapa sends POST /api/webhooks/chapa/ with:
    - tx_ref: "escrow-36f0f955-abc12345"
    - status: "success"
    - Chapa-Signature: [HMAC-SHA256]

11. Django (ChapaWebhookView):
    a. Recomputes HMAC and verifies signature
    b. Looks up PaymentTransaction by tx_ref
    c. Checks idempotency (already SUCCESS? return immediately)
    d. Marks PaymentTransaction.status = SUCCESS
    e. Calls record_escrow_funded(contract, payment_txn):
       - Opens transaction.atomic()
       - Creates LedgerTransaction (ESCROW_FUNDED)
       - Creates LedgerEntry: DEBIT buyer_wallet 850.00
       - Creates LedgerEntry: CREDIT platform_escrow_holding 850.00
       - Calls assert_balanced() → 850 == 850 ✓
       - Updates EscrowContract.status = FUNDED
       - Commits
    f. Calls notify_merchant_webhook() (fire-and-forget)
    g. Returns 200 {"message": "Escrow funded"}

12. Flutter: app resumes from browser → invalidates escrowListProvider
13. Contract now shows status=FUNDED to both parties
```

### Flow 2: Delivery Verification via QR Code

```
1. Seller ships the item
2. Seller calls POST /api/escrow/<id>/mark-shipped/
   → status changes to IN_TRANSIT

3. At delivery, seller shows the QR code (from qr_flutter, displaying delivery_qr_token)
4. Buyer opens Flutter app → Scan QR tab → scans with mobile_scanner

5. Scanner reads the UUID token from QR
6. Flutter calls: POST /api/escrow/<id>/confirm-delivery/ with:
   {"qr_token": "cf9dddf3-7e26-4e64-bcd7-079d3557279a"}

7. Django (ConfirmDeliveryView):
   a. Verifies request.user == contract.buyer
   b. Checks status is FUNDED or IN_TRANSIT
   c. Compares qr_token from request with contract.delivery_qr_token
   d. Match found → calls record_escrow_released(contract):
      - Opens transaction.atomic()
      - Creates LedgerTransaction (ESCROW_RELEASED)
      - Creates LedgerEntry: DEBIT platform_escrow_holding 850.00
      - Creates LedgerEntry: CREDIT seller_wallet 850.00
      - assert_balanced() ✓
      - Updates EscrowContract.status = COMPLETED
      - Creates Payout (status=QUEUED) for seller
      - Commits
   e. Calls notify_merchant_webhook(event="escrow.released")
   f. Returns 200 with completed contract

8. Flutter shows payment success screen to buyer
9. Seller sees status=COMPLETED and Payout=QUEUED
10. Payout processes to seller's bank/mobile money
```

### Flow 3: Fayda Registration

```
1. User taps "Sign up with Fayda" in Flutter
2. FaydaScanScreen opens camera (mobile_scanner)
3. Camera reads QR from back of Fayda ID card
4. Raw QR text sent to decodeAndVerify() (fayda_decoder.dart):
   a. Checks for :DLT: and :SIGN: markers
   b. Parses fields: name, V, A (FAN), G, D
   c. Verifies RS256 signature using NIDP public key (pointycastle)
   d. Returns FaydaSuccess with identity data
5. FaydaConfirmScreen shows: photo, name, DOB, gender
6. User enters phone number and role (BUYER/SELLER), sets password
7. Flutter calls POST /api/auth/register/ with raw_payload + phone + role + password
8. Django (RegisterView):
   a. Calls verify_and_decode(raw_payload) in fayda.py
   b. Verifies RS256 signature server-side (independent check)
   c. Creates User with:
      - fayda_number = identity.fan
      - legal_name = identity.full_name
      - gender = identity.gender
      - date_of_birth = identity.date_of_birth
      - kyc_verified = True
   d. Creates LedgerAccount (USER_WALLET) for the new user
   e. Returns token + user object
9. Flutter stores session → user is now logged in and KYC verified
```

---

*Document generated for internal presentation purposes — August 24, 2026*
*Escrow ET — Bridging Trust in Ethiopian Digital Commerce*
