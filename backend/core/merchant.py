import secrets

from django.db import IntegrityError

from .models import MerchantSettings, User


def generate_merchant_keys():
    return (
        f"pk_live_{secrets.token_hex(16)}",
        f"sk_live_{secrets.token_hex(24)}",
    )


def can_create_escrow(user: User) -> bool:
    return user.role in (User.Role.SELLER, User.Role.MERCHANT)


def get_or_create_merchant_settings(user: User) -> MerchantSettings:
    existing = MerchantSettings.objects.filter(merchant=user).first()
    if existing:
        return existing
    for _ in range(5):
        public_key, secret_key = generate_merchant_keys()
        try:
            return MerchantSettings.objects.create(
                merchant=user,
                public_key=public_key,
                secret_key=secret_key,
            )
        except IntegrityError:
            continue
    raise RuntimeError("Could not allocate unique merchant keys")
