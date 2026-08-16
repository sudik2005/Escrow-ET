from rest_framework import serializers

from .models import User


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