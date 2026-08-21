from rest_framework import serializers

from .models import User, EscrowContract, PaymentTransaction


class UserSerializer(serializers.ModelSerializer):
    balance = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id", "username", "email", "phone_number",
            "role", "kyc_verified", "created_at", "balance",
        ]
        read_only_fields = ["id", "kyc_verified", "created_at", "balance"]

    def get_balance(self, obj):
        ledger_account = getattr(obj, "ledger_account", None)
        return str(ledger_account.balance) if ledger_account else "0.00"


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ["username", "password", "email", "phone_number", "role"]

    def validate_role(self, value):
        allowed = (User.Role.BUYER, User.Role.SELLER, User.Role.MERCHANT)
        if value not in allowed:
            raise serializers.ValidationError(
                f"role must be one of: {', '.join(allowed)}"
            )
        return value

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
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