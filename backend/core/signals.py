from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import LedgerAccount


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_ledger_account_for_new_user(sender, instance, created, **kwargs):
    """
    Every User must have exactly one personal LedgerAccount (spec section 3).
    Creating it here means no view/serializer ever has to remember to do it
    manually - it happens the instant a User row is first saved.
    """
    if created:
        LedgerAccount.objects.get_or_create(
            owner=instance,
            defaults={"account_type": LedgerAccount.AccountType.USER_WALLET},
        )