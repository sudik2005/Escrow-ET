from rest_framework import serializers

from .fayda import FaydaError, FaydaIdentity, verify_and_decode
from .models import User, EscrowContract, PaymentTransaction


class UserSerializer(serializers.ModelSerializer):
    balance = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id", "username", "email", "phone_number",
            "role", "kyc_verified", "created_at", "balance",
            "legal_name", "gender", "fayda_number",
        ]
        read_only_fields = [
            "id", "kyc_verified", "created_at", "balance",
            "legal_name", "gender", "fayda_number",
        ]

    def get_balance(self, obj):
        ledger_account = getattr(obj, "ledger_account", None)
        return str(ledger_account.balance) if ledger_account else "0.00"


def _identity_from_payload(raw_payload: str) -> FaydaIdentity:
    try:
        return verify_and_decode(raw_payload)
    except FaydaError as exc:
        raise serializers.ValidationError({"raw_payload": str(exc)}) from exc


class RegisterSerializer(serializers.Serializer):
    raw_payload = serializers.CharField(write_only=True)
    phone_number = serializers.CharField(max_length=20)
    role = serializers.CharField()

    def validate_role(self, value):
        allowed = (User.Role.BUYER, User.Role.SELLER, User.Role.MERCHANT)
        if value not in allowed:
            raise serializers.ValidationError(
                f"role must be one of: {', '.join(allowed)}"
            )
        return value

    def validate_phone_number(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Phone number is required.")
        if User.objects.filter(phone_number=value).exists():
            raise serializers.ValidationError(
                "This phone number is already registered."
            )
        return value

    def validate(self, attrs):
        identity = _identity_from_payload(attrs["raw_payload"])
        if User.objects.filter(fayda_number=identity.fan).exists():
            raise serializers.ValidationError(
                {"raw_payload": "An account already exists for this Fayda ID."}
            )
        attrs["identity"] = identity
        return attrs

    def create(self, validated_data):
        identity: FaydaIdentity = validated_data["identity"]
        username = identity.fan
        if User.objects.filter(username=username).exists():
            username = f"fayda_{identity.fan}"
        user = User(
            username=username,
            phone_number=validated_data["phone_number"],
            role=validated_data["role"],
            fayda_number=identity.fan,
            legal_name=identity.full_name,
            gender=identity.gender or "",
            date_of_birth=identity.date_of_birth,
            kyc_verified=True,
        )
        user.set_unusable_password()
        user.save()
        return user

# Escrow contract serializers

class EscrowCreateSerializer(serializers.ModelSerializer):
    """
    POST /api/escrow/create/
    Seller (request.user) creates a contract for a buyer identified by
    phone number. verification_pin is write-only and never stored raw -
    it goes through EscrowContract.set_verification_pin(), which hashes
    it via Django's own password hasher.
    """

    buyer_phone = serializers.CharField(write_only=True)
    verification_pin = serializers.CharField(write_only=True, min_length=4, max_length=12)

    class Meta:
        model = EscrowContract
        fields = ["buyer_phone", "item_name", "amount", "currency", "verification_pin"]

    def validate_buyer_phone(self, value):
        try:
            self._buyer = User.objects.get(phone_number=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("No user found with this phone number")
        return value

    def create(self, validated_data):
        validated_data.pop("buyer_phone")
        raw_pin = validated_data.pop("verification_pin")
        seller = self.context["request"].user

        contract = EscrowContract(buyer=self._buyer, seller=seller, **validated_data)
        contract.set_verification_pin(raw_pin)
        contract.save()  # save() also auto-generates delivery_qr_token
        return contract


class EscrowContractSerializer(serializers.ModelSerializer):
    """
    Read serializer used by create/list/detail responses.

    Deliberately never exposes verification_pin, hashed or otherwise -
    the model stores it one-way hashed (make_password/check_password),
    so there is no raw value to return even if we wanted to. pin_is_set
    tells the client a PIN exists without revealing it; delivery_qr_token
    is what the client encodes into a QR code for delivery confirmation.
    """

    buyer_phone = serializers.CharField(source="buyer.phone_number", read_only=True)
    seller_phone = serializers.CharField(source="seller.phone_number", read_only=True)
    pin_is_set = serializers.SerializerMethodField()

    class Meta:
        model = EscrowContract
        fields = [
            "id",
            "buyer_phone",
            "seller_phone",
            "item_name",
            "amount",
            "currency",
            "status",
            "delivery_qr_token",
            "pin_is_set",
            "payment_link",
            "created_at",
            "updated_at",
        ]
        read_only_fields = fields

    def get_pin_is_set(self, obj):
        return bool(obj.verification_pin)


class ProfileUpdateSerializer(serializers.ModelSerializer):
    """
    PATCH /api/auth/me/
    Only username and role may be changed post-registration.
    Phone number is the identifier and cannot move; email and password
    have their own flows.
    """

    class Meta:
        model = User
        fields = ["username", "role"]

    def validate_role(self, value):
        allowed = (User.Role.BUYER, User.Role.SELLER, User.Role.MERCHANT)
        if value not in allowed:
            raise serializers.ValidationError(
                f"role must be one of: {', '.join(allowed)}"
            )
        return value

    def validate_username(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Username cannot be blank.")
        # Check uniqueness excluding the current user
        qs = User.objects.filter(username=value)
        if self.instance:
            qs = qs.exclude(pk=self.instance.pk)
        if qs.exists():
            raise serializers.ValidationError("This username is already taken.")
        return value


class ConfirmDeliverySerializer(serializers.Serializer):
    """
    POST /api/escrow/<id>/confirm-delivery/
    Buyer supplies EITHER qr_token OR pin (at least one required).
    """

    qr_token = serializers.UUIDField(required=False)
    pin = serializers.CharField(required=False)

    def validate(self, data):
        if not data.get("qr_token") and not data.get("pin"):
            raise serializers.ValidationError("Provide either qr_token or pin")
        return data


class DisputeCreateSerializer(serializers.Serializer):
    """POST /api/escrow/<id>/dispute/"""

    reason = serializers.CharField(min_length=5)