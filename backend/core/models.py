"""
Escrow ET data model: escrow state machine + double-entry ledger.
Financial truth is ledger entries, never a mutable balance column.
"""

from __future__ import annotations

import uuid
from decimal import Decimal

from django.conf import settings
from django.contrib.auth.hashers import check_password, make_password
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.core.validators import MinValueValidator, RegexValidator
from django.db import models, transaction


class User(AbstractUser):
    class Role(models.TextChoices):
        BUYER = "BUYER", "Buyer"
        SELLER = "SELLER", "Seller"
        MERCHANT = "MERCHANT", "Merchant"
        ADMIN = "ADMIN", "Admin"

    class Gender(models.TextChoices):
        MALE = "M", "Male"
        FEMALE = "F", "Female"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(max_length=20, unique=True)
    role = models.CharField(max_length=16, choices=Role.choices, default=Role.BUYER)
    kyc_verified = models.BooleanField(default=False)
    fayda_number = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True,
        db_index=True,
        validators=[
            RegexValidator(r"^\d{10,20}$", "Fayda number must be 10–20 digits."),
        ],
        help_text="Fayda Account Number from the national ID card QR.",
    )
    legal_name = models.CharField(max_length=255, blank=True, default="")
    gender = models.CharField(
        max_length=1,
        choices=Gender.choices,
        blank=True,
        default="",
    )
    date_of_birth = models.DateField(null=True, blank=True)
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
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    currency = models.CharField(max_length=8, default="ETB")
    status = models.CharField(
        max_length=32,
        choices=Status.choices,
        default=Status.PENDING_PAYMENT,
        db_index=True,
    )
    verification_pin = models.CharField(max_length=255)
    delivery_qr_token = models.UUIDField(unique=True, null=True, blank=True)
    payment_link = models.URLField(unique=True, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

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

    def clean(self) -> None:
        if self.buyer_id and self.seller_id and self.buyer_id == self.seller_id:
            raise ValidationError("Buyer and seller must be different users.")

    def set_verification_pin(self, raw_pin: str) -> None:
        self.verification_pin = make_password(raw_pin)

    def check_verification_pin(self, raw_pin: str) -> bool:
        return check_password(raw_pin, self.verification_pin)

    def save(self, *args, **kwargs):
        if not self.delivery_qr_token:
            self.delivery_qr_token = uuid.uuid4()
        super().save(*args, **kwargs)


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
    status = models.CharField(
        max_length=32,
        choices=Status.choices,
        default=Status.OPEN,
        db_index=True,
    )
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

    SYSTEM_ACCOUNT_TYPES = (
        AccountType.PLATFORM_ESCROW_HOLDING,
        AccountType.PLATFORM_FEE_REVENUE,
        AccountType.PLATFORM_PAYOUT_CLEARING,
    )

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    account_type = models.CharField(max_length=32, choices=AccountType.choices)
    owner = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.PROTECT,
        related_name="ledger_account",
    )
    currency = models.CharField(max_length=8, default="ETB")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["account_type"],
                condition=models.Q(owner__isnull=True),
                name="uniq_system_ledger_account",
            ),
        ]

    @property
    def balance(self) -> Decimal:
        credits = self.entries.filter(direction=LedgerEntry.Direction.CREDIT).aggregate(
            total=models.Sum("amount")
        )["total"] or Decimal("0.00")
        debits = self.entries.filter(direction=LedgerEntry.Direction.DEBIT).aggregate(
            total=models.Sum("amount")
        )["total"] or Decimal("0.00")
        return credits - debits

    @classmethod
    def get_system_account(cls, account_type: str) -> "LedgerAccount":
        if account_type not in cls.SYSTEM_ACCOUNT_TYPES:
            raise ValidationError("Not a platform ledger account type")
        account, _ = cls.objects.get_or_create(account_type=account_type, owner=None)
        return account


class LedgerTransaction(models.Model):
    class TransactionType(models.TextChoices):
        ESCROW_FUNDED = "ESCROW_FUNDED", "Escrow Funded"
        ESCROW_RELEASED = "ESCROW_RELEASED", "Escrow Released to Seller"
        ESCROW_REFUNDED = "ESCROW_REFUNDED", "Escrow Refunded to Buyer"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    transaction_type = models.CharField(max_length=32, choices=TransactionType.choices)
    escrow_contract = models.ForeignKey(
        EscrowContract, on_delete=models.PROTECT, related_name="ledger_transactions"
    )
    payment_transaction = models.ForeignKey(
        "PaymentTransaction", null=True, blank=True, on_delete=models.SET_NULL
    )
    memo = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["escrow_contract", "transaction_type"],
                name="uniq_ledger_txn_per_escrow_type",
            ),
        ]

    def assert_balanced(self) -> None:
        totals = self.entries.aggregate(
            debits=models.Sum(
                "amount",
                filter=models.Q(direction=LedgerEntry.Direction.DEBIT),
            ),
            credits=models.Sum(
                "amount",
                filter=models.Q(direction=LedgerEntry.Direction.CREDIT),
            ),
        )
        debits = totals["debits"] or Decimal("0.00")
        credits = totals["credits"] or Decimal("0.00")
        if debits != credits:
            raise ValidationError("LedgerTransaction does not balance")


class LedgerEntry(models.Model):
    class Direction(models.TextChoices):
        DEBIT = "DEBIT", "Debit"
        CREDIT = "CREDIT", "Credit"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ledger_transaction = models.ForeignKey(
        LedgerTransaction, on_delete=models.CASCADE, related_name="entries"
    )
    account = models.ForeignKey(LedgerAccount, on_delete=models.PROTECT, related_name="entries")
    direction = models.CharField(max_length=8, choices=Direction.choices)
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=models.Q(amount__gt=0),
                name="ledger_entry_amount_positive",
            ),
        ]


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
    escrow_contract = models.ForeignKey(
        EscrowContract, on_delete=models.PROTECT, related_name="payment_transactions"
    )
    provider = models.CharField(max_length=16, choices=Provider.choices, default=Provider.CHAPA)
    direction = models.CharField(max_length=20, choices=Direction.choices)
    status = models.CharField(
        max_length=16,
        choices=Status.choices,
        default=Status.INITIATED,
        db_index=True,
    )
    provider_tx_ref = models.CharField(max_length=128, unique=True)
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    currency = models.CharField(max_length=8, default="ETB")
    raw_payload = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=models.Q(amount__gt=0),
                name="payment_amount_positive",
            ),
        ]


class Payout(models.Model):
    class Status(models.TextChoices):
        QUEUED = "QUEUED", "Queued"
        PROCESSING = "PROCESSING", "Processing"
        SUCCESS = "SUCCESS", "Success"
        FAILED = "FAILED", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    escrow_contract = models.OneToOneField(
        EscrowContract, on_delete=models.PROTECT, related_name="payout"
    )
    seller = models.ForeignKey(User, on_delete=models.PROTECT, related_name="payouts")
    amount = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(Decimal("0.01"))],
    )
    status = models.CharField(max_length=16, choices=Status.choices, default=Status.QUEUED)
    provider_payout_ref = models.CharField(max_length=128, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.CheckConstraint(
                condition=models.Q(amount__gt=0),
                name="payout_amount_positive",
            ),
        ]


def _post_two_sided_entry(
    *,
    transaction_type: str,
    escrow_contract: EscrowContract,
    debit_account: LedgerAccount,
    credit_account: LedgerAccount,
    payment_transaction: "PaymentTransaction | None" = None,
) -> LedgerTransaction:
    ledger_tx = LedgerTransaction.objects.create(
        transaction_type=transaction_type,
        escrow_contract=escrow_contract,
        payment_transaction=payment_transaction,
    )
    LedgerEntry.objects.create(
        ledger_transaction=ledger_tx,
        account=debit_account,
        direction=LedgerEntry.Direction.DEBIT,
        amount=escrow_contract.amount,
    )
    LedgerEntry.objects.create(
        ledger_transaction=ledger_tx,
        account=credit_account,
        direction=LedgerEntry.Direction.CREDIT,
        amount=escrow_contract.amount,
    )
    ledger_tx.assert_balanced()
    return ledger_tx


def record_escrow_funded(
    escrow_contract: EscrowContract, payment_transaction: PaymentTransaction
) -> LedgerTransaction:
    with transaction.atomic():
        ledger_tx = _post_two_sided_entry(
            transaction_type=LedgerTransaction.TransactionType.ESCROW_FUNDED,
            escrow_contract=escrow_contract,
            debit_account=escrow_contract.buyer.ledger_account,
            credit_account=LedgerAccount.get_system_account(
                LedgerAccount.AccountType.PLATFORM_ESCROW_HOLDING
            ),
            payment_transaction=payment_transaction,
        )
        escrow_contract.status = EscrowContract.Status.FUNDED
        escrow_contract.save(update_fields=["status", "updated_at"])
        return ledger_tx


def record_escrow_released(escrow_contract: EscrowContract) -> LedgerTransaction:
    with transaction.atomic():
        ledger_tx = _post_two_sided_entry(
            transaction_type=LedgerTransaction.TransactionType.ESCROW_RELEASED,
            escrow_contract=escrow_contract,
            debit_account=LedgerAccount.get_system_account(
                LedgerAccount.AccountType.PLATFORM_ESCROW_HOLDING
            ),
            credit_account=escrow_contract.seller.ledger_account,
        )
        escrow_contract.status = EscrowContract.Status.COMPLETED
        escrow_contract.save(update_fields=["status", "updated_at"])
        Payout.objects.create(
            escrow_contract=escrow_contract,
            seller=escrow_contract.seller,
            amount=escrow_contract.amount,
            status=Payout.Status.QUEUED,
        )
        return ledger_tx


def record_escrow_refunded(escrow_contract: EscrowContract) -> LedgerTransaction:
    with transaction.atomic():
        ledger_tx = _post_two_sided_entry(
            transaction_type=LedgerTransaction.TransactionType.ESCROW_REFUNDED,
            escrow_contract=escrow_contract,
            debit_account=LedgerAccount.get_system_account(
                LedgerAccount.AccountType.PLATFORM_ESCROW_HOLDING
            ),
            credit_account=escrow_contract.buyer.ledger_account,
        )
        escrow_contract.status = EscrowContract.Status.CANCELLED
        escrow_contract.save(update_fields=["status", "updated_at"])
        return ledger_tx
