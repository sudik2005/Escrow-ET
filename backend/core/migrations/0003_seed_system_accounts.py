from django.db import migrations


SYSTEM_TYPES = (
    "PLATFORM_ESCROW_HOLDING",
    "PLATFORM_FEE_REVENUE",
    "PLATFORM_PAYOUT_CLEARING",
)


def seed_system_accounts(apps, schema_editor):
    LedgerAccount = apps.get_model("core", "LedgerAccount")
    for account_type in SYSTEM_TYPES:
        LedgerAccount.objects.get_or_create(
            account_type=account_type,
            owner=None,
            defaults={"currency": "ETB"},
        )


def unseed_system_accounts(apps, schema_editor):
    LedgerAccount = apps.get_model("core", "LedgerAccount")
    LedgerAccount.objects.filter(
        owner__isnull=True,
        account_type__in=SYSTEM_TYPES,
    ).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("core", "0002_schema_harden"),
    ]

    operations = [
        migrations.RunPython(seed_system_accounts, unseed_system_accounts),
    ]
