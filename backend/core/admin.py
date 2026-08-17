from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from .models import (
    Dispute,
    DisputeMessage,
    EscrowContract,
    LedgerAccount,
    LedgerEntry,
    LedgerTransaction,
    MerchantSettings,
    Payout,
    PaymentTransaction,
    User,
)


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    list_display = ("username", "phone_number", "role", "kyc_verified", "is_staff")
    list_filter = ("role", "kyc_verified", "is_staff")
    fieldsets = DjangoUserAdmin.fieldsets + (
        ("Escrow ET info", {"fields": ("phone_number", "role", "kyc_verified")}),
    )


@admin.register(EscrowContract)
class EscrowContractAdmin(admin.ModelAdmin):
    list_display = ("id", "item_name", "buyer", "seller", "amount", "currency", "status", "created_at")
    list_filter = ("status", "currency")
    search_fields = ("item_name", "buyer__username", "seller__username", "payment_link")
    readonly_fields = ("id", "verification_pin", "created_at", "updated_at")


@admin.register(Dispute)
class DisputeAdmin(admin.ModelAdmin):
    list_display = ("id", "escrow", "opened_by", "status", "created_at")
    list_filter = ("status",)
    search_fields = ("escrow__id", "opened_by__username", "reason")


@admin.register(DisputeMessage)
class DisputeMessageAdmin(admin.ModelAdmin):
    list_display = ("id", "dispute", "sender", "created_at")
    search_fields = ("dispute__id", "sender__username", "message")


@admin.register(MerchantSettings)
class MerchantSettingsAdmin(admin.ModelAdmin):
    list_display = ("id", "merchant", "public_key", "webhook_url")
    search_fields = ("merchant__username", "public_key")
    readonly_fields = ("secret_key",)


@admin.register(LedgerAccount)
class LedgerAccountAdmin(admin.ModelAdmin):
    list_display = ("id", "account_type", "owner", "currency", "balance", "created_at")
    list_filter = ("account_type", "currency")

    @admin.display(description="Balance")
    def balance(self, obj):
        return obj.balance


@admin.register(LedgerTransaction)
class LedgerTransactionAdmin(admin.ModelAdmin):
    list_display = ("id", "transaction_type", "escrow_contract", "created_at")
    list_filter = ("transaction_type",)
    readonly_fields = ("id", "created_at")


@admin.register(LedgerEntry)
class LedgerEntryAdmin(admin.ModelAdmin):
    list_display = ("id", "ledger_transaction", "account", "direction", "amount", "created_at")
    list_filter = ("direction",)


@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = ("id", "escrow_contract", "provider", "direction", "status", "amount", "provider_tx_ref")
    list_filter = ("provider", "direction", "status")
    search_fields = ("provider_tx_ref", "escrow_contract__id")
    readonly_fields = ("raw_payload",)


@admin.register(Payout)
class PayoutAdmin(admin.ModelAdmin):
    list_display = ("id", "escrow_contract", "seller", "amount", "status", "provider_payout_ref")
    list_filter = ("status",)