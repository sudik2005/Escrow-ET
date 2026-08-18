"""
Thin wrapper around Chapa's sandbox API: starting a payment and verifying
webhook signatures. No Django model code here on purpose - keeps this
testable and swappable if the payment provider ever changes.
"""

import hashlib
import hmac

import requests
from django.conf import settings

CHAPA_BASE_URL = "https://api.chapa.co/v1"


class ChapaError(Exception):
    """Raised when Chapa's API returns an error or is unreachable."""


def initialize_transaction(
    *, email, amount, currency, tx_ref, callback_url, return_url,
    first_name="", last_name="",
):
    """
    Calls Chapa's /transaction/initialize endpoint. Returns the hosted
    checkout URL the buyer should be redirected to. Raises ChapaError
    on any failure - callers should not need to know requests internals.
    """
    try:
        response = requests.post(
            f"{CHAPA_BASE_URL}/transaction/initialize",
            headers={"Authorization": f"Bearer {settings.CHAPA_SECRET_KEY}"},
            json={
                "amount": str(amount),
                "currency": currency,
                "email": email,
                "first_name": first_name,
                "last_name": last_name,
                "tx_ref": tx_ref,
                "callback_url": callback_url,
                "return_url": return_url,
            },
            timeout=10,
        )
    except requests.RequestException as exc:
        raise ChapaError(f"Could not reach Chapa: {exc}") from exc

    data = response.json()
    if response.status_code != 200 or data.get("status") != "success":
        raise ChapaError(f"Chapa rejected the request: {data}")

    return data["data"]["checkout_url"]


def verify_webhook_signature(raw_body: bytes, signature_header: str) -> bool:
    """
    Chapa signs webhook payloads with HMAC-SHA256 using the webhook
    secret. We recompute it ourselves and compare - this is what proves
    a webhook actually came from Chapa and wasn't forged.
    """
    if not signature_header or not settings.CHAPA_WEBHOOK_SECRET:
        return False

    expected = hmac.new(
        settings.CHAPA_WEBHOOK_SECRET.encode(),
        raw_body,
        hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(expected, signature_header)