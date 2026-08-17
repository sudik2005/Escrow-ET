"""
Escrow ET — Full Data Model
===========================================

Single source of truth combining:
  1. The core platform schema (Users, EscrowContracts, Disputes,
     DisputeMessages, MerchantSettings) from the original blueprint.
  2. The double-entry ledger + escrow engine that sits underneath it,
     designed to run on a licensed PSP sandbox (e.g. Chapa test mode)
     rather than custody real money directly.
"""

import uuid
from decimal import Decimal

from django.conf import settings
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models, transaction


class User(AbstractUser):
    class Role(models.TextChoices):
        BUYER = "BUYER", "Buyer"
        SELLER = "SELLER", "Seller"
        MERCHANT = "MERCHANT", "Merchant"
        ADMIN = "ADMIN", "Admin"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(max_length=20, unique=True)
    role = models.CharField(max_length=16, choices=Role.choices, default=Role.BUYER)
    kyc_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.phone_number} ({self.role})"


class EscrowContract(models.Model):
    class Status(models.TextChoices):
        PENDING_PAYMENT = "PENDING_PAYMENT", "Pending Payment"
        FUNDED = "FUNDED", "Funded"
        IN_TRANSIT = "IN_TRANSIT", "In Transit"
        DELIVERED_UNVERIFIED = "DELIVERED_UNVERIFIED", "Delivered (Unverified)"
        COMPLETED = "COMPLETED", "Completed"
        DISPUTED = "DISPUTED", "Disputed"
        CANCELLED = "CANCELLED", "Cancelled"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    buyer = models.ForeignKey(User, on_delete=models.PROTECT, related_name="purchases_as_buyer")
    seller = models.ForeignKey(User, on_delete=models.PROTECT, related_name="sales_as_seller")
    item_name = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=8, default="ETB")
    status = models.CharField(max_length=32, choices=Status.choices, default=Status.PENDING_PAYMENT)
    verification_pin = models.CharField(max_length=255)
    payment_link = models.URLField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


class Dispute(models.Model):
    class Status(models.TextChoices):
        OPEN = "OPEN", "Open"
        UNDER_REVIEW = "UNDER_REVIEW", "Under Review"
        RESOLVED_REFUNDED = "RESOLVED_REFUNDED", "Resolved - Refunded"
        RESOLVED_RELEASED = "RESOLVED_RELEASED", "Resolved - Released"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    escrow = models.OneToOneField(EscrowContract, on_delete=models.PROTECT, related_name="dispute")
    opened_by = models.ForeignKey(User, on_delete=models.PROTECT, related_name="disputes_opened")
    reason = models.TextField()
    status = models.CharField(max_length=32, choices=Status.choices, default=Status.OPEN)
    created_at = models.DateTimeField(auto_now_add=True)


class DisputeMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    dispute = models.ForeignKey(Dispute, on_delete=models.CASCADE, related_name="messages")
    sender = models.ForeignKey(User, on_delete=models.PROTECT, related_name="dispute_messages")
    message = models.TextField()
    attachment_url = models.URLField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class MerchantSettings(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    merchant = models.OneToOneField(User, on_delete=models.PROTECT, related_name="merchant_settings")
    public_key = models.CharField(max_length=255, unique=True)
    secret_key = models.CharField(max_length=255)
    webhook_url = models.URLField(null=True, blank=True)


class LedgerAccount(models.Model):
    class AccountType(models.TextChoices):
        USER_WALLET = "USER_WALLET", "User Wallet"
        PLATFORM_ESCROW_HOLDING = "PLATFORM_ESCROW_HOLDING", "Platform Escrow Holding"
        PLATFORM_FEE_REVENUE = "PLATFORM_FEE_REVENUE", "Platform Fee Revenue"
        PLATFORM_PAYOUT_CLEARING = "PLATFORM_PAYOUT_CLEARING", "Platform Payout Clearing"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    account_type = models.CharField(max_length=32, choices=AccountType.choices)
    owner = models.OneToOneField(settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.PROTECT, related_name="ledger_account")
    currency = models.CharField(max_length=8, default="ETB")
    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def balance(self) -> Decimal:
        credits = self.entries.filter(direction=LedgerEntry.Direction.CREDIT).aggregate(total=models.Sum("amount"))["total"] or Decimal("0.00")
        debits = self.entries.filter(direction=LedgerEntry.Direction.DEBIT).aggregate(total=models.Sum("amount"))["total"] or Decimal("0.00")
        return credits - debits

    @classmethod
    def get_system_account(cls, account_type: str) -> "LedgerAccount":
        account, _ = cls.objects.get_or_create(account_type=account_type, owner=None)
        return account


class LedgerTransaction(models.Model):
    class TransactionType(models.TextChoices):
        ESCROW_FUNDED = "ESCROW_FUNDED", "Escrow Funded"
        ESCROW_RELEASED = "ESCROW_RELEASED", "Escrow Released to Seller"
        ESCROW_REFUNDED = "ESCROW_REFUNDED", "Escrow Refunded to Buyer"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transaction_type = models.CharField(max_length=32, choices=TransactionType.choices)
    escrow_contract = models.ForeignKey(EscrowContract, on_delete=models.PROTECT, related_name="ledger_transactions")
    payment_transaction = models.ForeignKey("PaymentTransaction", null=True, blank=True, on_delete=models.SET_NULL)
    memo = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        total_debits = sum(e.amount for e in self.entries.filter(direction=LedgerEntry.Direction.DEBIT))
        total_credits = sum(e.amount for e in self.entries.filter(direction=LedgerEntry.Direction.CREDIT))
        if total_debits != total_credits:
            raise ValidationError("LedgerTransaction does not balance")


class LedgerEntry(models.Model):
    class Direction(models.TextChoices):
        DEBIT = "DEBIT", "Debit"
        CREDIT = "CREDIT", "Credit"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ledger_transaction = models.ForeignKey(LedgerTransaction, on_delete=models.CASCADE, related_name="entries")
    account = models.ForeignKey(LedgerAccount, on_delete=models.PROTECT, related_name="entries")
    direction = models.CharField(max_length=8, choices=Direction.choices)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)


class PaymentTransaction(models.Model):
    class Provider(models.TextChoices):
        CHAPA = "CHAPA", "Chapa"
        MOCK = "MOCK", "Mock Gateway"

    class Direction(models.TextChoices):
        INBOUND_FUNDING = "INBOUND_FUNDING", "Buyer funding escrow"
        OUTBOUND_PAYOUT = "OUTBOUND_PAYOUT", "Payout to seller"

    class Status(models.TextChoices):
        INITIATED = "INITIATED", "Initiated"
        SUCCESS = "SUCCESS", "Success"
        FAILED = "FAILED", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    escrow_contract = models.ForeignKey(EscrowContract, on_delete=models.PROTECT, related_name="payment_transactions")
    provider = models.CharField(max_length=16, choices=Provider.choices, default=Provider.CHAPA)
    direction = models.CharField(max_length=20, choices=Direction.choices)
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.INITIATED)
    provider_tx_ref = models.CharField(max_length=128, unique=True)
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.CharField(max_length=8, default="ETB")
    raw_payload = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class Payout(models.Model):
    class Status(models.TextChoices):
        QUEUED = "QUEUED", "Queued"
        PROCESSING = "PROCESSING", "Processing"
        SUCCESS = "SUCCESS", "Success"
        FAILED = "FAILED", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    escrow_contract = models.OneToOneField(EscrowContract, on_delete=models.PROTECT, related_name="payout")
    seller = models.ForeignKey(User, on_delete=models.PROTECT, related_name="payouts")
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.QUEUED)
    provider_payout_ref = models.CharField(max_length=128, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


# ===========================================================================
# SERVICE FUNCTIONS (Must run in transaction.atomic)
# ===========================================================================

def record_escrow_funded(escrow_contract: EscrowContract, payment_transaction: PaymentTransaction) -> LedgerTransaction:
    with transaction.atomic():
        buyer_account = escrow_contract.buyer.ledger_account
        holding_account = LedgerAccount.get_system_account(LedgerAccount.AccountType.PLATFORM_ESCROW_HOLDING)

        ledger_tx = LedgerTransaction.objects.create(
            transaction_type=LedgerTransaction.TransactionType.ESCROW_FUNDED,
            escrow_contract=escrow_contract,
            payment_transaction=payment_transaction,
        )
        LedgerEntry.objects.create(ledger_transaction=ledger_tx, account=buyer_account, direction=LedgerEntry.Direction.DEBIT, amount=escrow_contract.amount)
        LedgerEntry.objects.create(ledger_transaction=ledger_tx, account=holding_account, direction=LedgerEntry.Direction.CREDIT, amount=escrow_contract.amount)
        ledger_tx.clean()

        escrow_contract.status = EscrowContract.Status.FUNDED
        escrow_contract.save(update_fields=["status", "updated_at"])
        return ledger_tx


def record_escrow_released(escrow_contract: EscrowContract) -> LedgerTransaction:
    with transaction.atomic():
        holding_account = LedgerAccount.get_system_account(LedgerAccount.AccountType.PLATFORM_ESCROW_HOLDING)
        seller_account = escrow_contract.seller.ledger_account

        ledger_tx = LedgerTransaction.objects.create(
            transaction_type=LedgerTransaction.TransactionType.ESCROW_RELEASED,
            escrow_contract=escrow_contract,
        )
        LedgerEntry.objects.create(ledger_transaction=ledger_tx, account=holding_account, direction=LedgerEntry.Direction.DEBIT, amount=escrow_contract.amount)
        LedgerEntry.objects.create(ledger_transaction=ledger_tx, account=seller_account, direction=LedgerEntry.Direction.CREDIT, amount=escrow_contract.amount)
        ledger_tx.clean()

        escrow_contract.status = EscrowContract.Status.COMPLETED
        escrow_contract.save(update_fields=["status", "updated_at"])

        Payout.objects.create(escrow_contract=escrow_contract, seller=escrow_contract.seller, amount=escrow_contract.amount, status=Payout.Status.QUEUED)
        return ledger_tx