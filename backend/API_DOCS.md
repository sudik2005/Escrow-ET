api _documentations

 1. Create — POST /api/escrow/create/ (seller token required)

// Request
{"buyer_phone": "0922000001", "item_name": "Bluetooth Speaker", "amount": "850.00", "verification_pin": "9911"}

// Response (201)
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

2. List My Escrows — GET /api/escrow/mine/
Buyer or seller. Returns all contracts where the user is involved.

json
// Response (200)
[
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
]
3. Get One Escrow — GET /api/escrow/<id>/
Buyer or seller only. Returns details of a single contract.

json
// Response (200)
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
4. Mark Shipped — POST /api/escrow/<id>/mark-shipped/
Seller only. Moves contract from FUNDED → IN_TRANSIT.

json
// Response (200)
{
  "id": "36f0f955-3812-4b2d-84b7-72f998e0510c",
  "status": "IN_TRANSIT",
  "updated_at": "2026-08-18T14:00:00.000000+03:00",
  "... other fields same as above ..."
}
5. Confirm Delivery — POST /api/escrow/<id>/confirm-delivery/
Buyer only. Accepts either qr_token or pin. Moves contract to COMPLETED.

json
// Request (using PIN)
{
  "pin": "9911"
}

// Response (200)
{
  "id": "36f0f955-3812-4b2d-84b7-72f998e0510c",
  "status": "COMPLETED",
  "updated_at": "2026-08-18T14:30:00.000000+03:00",
  "... other fields same as above ..."
}
6. Open Dispute — POST /api/escrow/<id>/dispute/
Buyer or seller. Allowed once funds are locked, before completion/cancellation.

json
// Request
{
  "reason": "Item arrived damaged"
}

// Response (201)
{
  "id": "36f0f955-3812-4b2d-84b7-72f998e0510c",
  "status": "DISPUTED",
  "updated_at": "2026-08-18T15:00:00.000000+03:00",
  "... other fields same as above ..."
}
7. Chapa Webhook — POST /api/webhooks/chapa/
Called by Chapa itself. No auth token. Validates HMAC signature. Updates escrow funding status.

json
// Request (from Chapa)
{
  "tx_ref": "escrow-36f0f955-3812-4b2d-84b7-72f998e0510c-abc12345",
  "status": "success"
}

// Response (200)
{
  "message": "Escrow funded"
}

Conclusive Summary

The escrow backend is now fully structured around six core endpoints, plus supporting payment and webhook flows. The system is designed so that sellers can create contracts, buyers can fund them through Chapa, and both parties can track, confirm, or dispute the transaction. PINs are stored securely (hashed like passwords) and never exposed — instead, the API signals whether a PIN is set. Every response follows a consistent JSON shape, making it predictable for clients.