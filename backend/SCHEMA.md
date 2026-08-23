# Escrow ET database schema

Supabase PostgreSQL. Django ORM in `backend/core/models.py` is the source of truth.

```mermaid
erDiagram
  core_user ||--o{ core_escrowcontract : buyer
  core_user ||--o{ core_escrowcontract : seller
  core_user ||--o| core_ledgeraccount : wallet
  core_user ||--o| core_merchantsettings : merchant
  core_escrowcontract ||--o| core_dispute : dispute
  core_escrowcontract ||--o{ core_ledgertransaction : postings
  core_escrowcontract ||--o{ core_paymenttransaction : chapa
  core_escrowcontract ||--o| core_payout : payout
  core_dispute ||--o{ core_disputemessage : messages
  core_ledgertransaction ||--|{ core_ledgerentry : lines
  core_ledgeraccount ||--o{ core_ledgerentry : account
  core_paymenttransaction ||--o{ core_ledgertransaction : optional

  core_user {
    uuid id PK
    varchar phone_number UK
    varchar role
    bool kyc_verified
    varchar fayda_number UK
    varchar legal_name
    varchar gender
    date date_of_birth
  }
  core_escrowcontract {
    uuid id PK
    uuid buyer_id FK
    uuid seller_id FK
    numeric amount
    varchar status
    varchar verification_pin
    uuid delivery_qr_token UK
    varchar payment_link UK
  }
  core_ledgeraccount {
    uuid id PK
    varchar account_type
    uuid owner_id UK
  }
  core_ledgertransaction {
    uuid id PK
    varchar transaction_type
    uuid escrow_contract_id FK
  }
  core_ledgerentry {
    uuid id PK
    uuid ledger_transaction_id FK
    uuid account_id FK
    varchar direction
    numeric amount
  }
```





## Domain tables


| Table                     | Purpose                                                                                                                            |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `core_user`               | BUYER / SELLER / MERCHANT / ADMIN. Fayda signup stores `fayda_number` (unique FAN), `legal_name`, `gender`, `date_of_birth`, and sets `kyc_verified` |
| `core_escrowcontract`     | One deal. Status: `PENDING_PAYMENT` → `FUNDED` → `IN_TRANSIT` → `DELIVERED_UNVERIFIED` → `COMPLETED` (or `DISPUTED` / `CANCELLED`) |
| `core_dispute`            | One dispute per escrow                                                                                                             |
| `core_disputemessage`     | Dispute thread                                                                                                                     |
| `core_merchantsettings`   | Merchant API keys + webhook                                                                                                        |
| `core_ledgeraccount`      | User wallet (`owner_id`) or platform vault (`owner_id` NULL)                                                                       |
| `core_ledgertransaction`  | Immutable posting header: `ESCROW_FUNDED` / `ESCROW_RELEASED` / `ESCROW_REFUNDED`                                                  |
| `core_ledgerentry`        | Debit or credit line. Amount `> 0`. Debits must equal credits                                                                      |
| `core_paymenttransaction` | Chapa/mock bridge (`provider_tx_ref` unique, `raw_payload` jsonb)                                                                  |
| `core_payout`             | Seller payout after release (one per escrow)                                                                                       |




## Platform accounts (seeded)

- `PLATFORM_ESCROW_HOLDING`
- `PLATFORM_FEE_REVENUE`
- `PLATFORM_PAYOUT_CLEARING`

Balance is **not** a column. It is credits minus debits on `core_ledgerentry`. Ledger rows cannot be updated or deleted.

## Ledger postings


| Function                 | Debit        | Credit        | Escrow status after           |
| ------------------------ | ------------ | ------------- | ----------------------------- |
| `record_escrow_funded`   | buyer wallet | HOLDING       | `FUNDED`                      |
| `record_escrow_released` | HOLDING      | seller wallet | `COMPLETED` (+ payout queued) |
| `record_escrow_refunded` | HOLDING      | buyer wallet  | `CANCELLED`                   |


