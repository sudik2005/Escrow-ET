import json
import logging
import urllib.error
import urllib.request

from .models import MerchantSettings

logger = logging.getLogger(__name__)


def notify_merchant_webhook(escrow, event: str) -> None:
    settings_obj = MerchantSettings.objects.filter(merchant=escrow.seller).first()
    if not settings_obj or not settings_obj.webhook_url:
        return
    payload = json.dumps(
        {
            "event": event,
            "escrow_id": str(escrow.id),
            "status": escrow.status,
            "amount": str(escrow.amount),
            "currency": escrow.currency,
        }
    ).encode("utf-8")
    request = urllib.request.Request(
        settings_obj.webhook_url,
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        urllib.request.urlopen(request, timeout=5)
    except (urllib.error.URLError, TimeoutError, ValueError) as exc:
        logger.warning("Merchant webhook failed for %s: %s", escrow.id, exc)
