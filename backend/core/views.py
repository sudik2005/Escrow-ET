import uuid

from django.conf import settings
from django.contrib.auth import authenticate
from django.db import models
from django.shortcuts import get_object_or_404
from django.urls import reverse
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from . import chapa
from .fayda import FaydaError, verify_and_decode
from .models import (
    Dispute,
    EscrowContract,
    PaymentTransaction,
    User,
    record_escrow_funded,
    record_escrow_released,
)
from .serializers import (
    ConfirmDeliverySerializer,
    DisputeCreateSerializer,
    EscrowContractSerializer,
    EscrowCreateSerializer,
    ProfileUpdateSerializer,
    RegisterSerializer,
    UserSerializer,
)

class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        return Response(
            {"token": token.key, "user": UserSerializer(user).data},
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        raw_payload = request.data.get("raw_payload")
        if raw_payload:
            return self._login_with_fayda(raw_payload)
        username = request.data.get("username", "")
        password = request.data.get("password", "")
        user = authenticate(request, username=username, password=password)
        if user is None:
            return Response(
                {"error": "Invalid username or password"},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        token, _ = Token.objects.get_or_create(user=user)
        return Response({"token": token.key, "user": UserSerializer(user).data})

    def _login_with_fayda(self, raw_payload):
        try:
            identity = verify_and_decode(raw_payload)
        except FaydaError as exc:
            return Response(
                {"error": str(exc)},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        try:
            user = User.objects.get(fayda_number=identity.fan)
        except User.DoesNotExist:
            return Response(
                {"error": "No account for this Fayda ID. Sign up first."},
                status=status.HTTP_404_NOT_FOUND,
            )
        token, _ = Token.objects.get_or_create(user=user)
        return Response({"token": token.key, "user": UserSerializer(user).data})


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            request.user.auth_token.delete()
        except Exception:
            pass
        return Response({"message": "Logged out"})


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)

    def patch(self, request):
        serializer = ProfileUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserSerializer(request.user).data)

# api-create, list, get, mark shipped, confirm delivery and many more
# 1. Create escrow

class EscrowCreateView(APIView):
    """
    POST /api/escrow/create/
    Only sellers create escrow contracts. Buyer is looked up by phone
    number. Attempts to start a Chapa checkout immediately so the
    response can include payment_link right away when possible - if
    Chapa is unreachable or not configured, the contract is still
    created with payment_link null, and /pay/ can be used to retry.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != request.user.Role.SELLER:
            return Response(
                {"error": "Only sellers can create escrow contracts"},
                status=status.HTTP_403_FORBIDDEN,
            )

        serializer = EscrowCreateSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        contract = serializer.save()

        _try_initiate_chapa_payment(request, contract)

        return Response(
            EscrowContractSerializer(contract).data,
            status=status.HTTP_201_CREATED,
        )


def _try_initiate_chapa_payment(request, contract):
    """
    Best-effort Chapa initialization shared by create + the explicit
    /pay/ retry endpoint. Never raises - failures just leave
    payment_link as None.
    """
    tx_ref = f"escrow-{contract.id}-{uuid.uuid4().hex[:8]}"
    callback_url = request.build_absolute_uri(reverse("chapa-webhook"))

    try:
        checkout_url = chapa.initialize_transaction(
            email=contract.buyer.email or f"{contract.buyer.phone_number}@example.com",
            amount=contract.amount,
            currency=contract.currency,
            tx_ref=tx_ref,
            callback_url=callback_url,
            return_url=callback_url,
            first_name=contract.buyer.first_name or contract.buyer.username or "Buyer",
            last_name=contract.buyer.last_name or contract.buyer.phone_number or "User",
        )
    except chapa.ChapaError:
        return  # contract still exists, payment_link stays null

    PaymentTransaction.objects.create(
        escrow_contract=contract,
        provider=PaymentTransaction.Provider.CHAPA,
        direction=PaymentTransaction.Direction.INBOUND_FUNDING,
        status=PaymentTransaction.Status.INITIATED,
        provider_tx_ref=tx_ref,
        amount=contract.amount,
        currency=contract.currency,
    )
    contract.payment_link = checkout_url
    contract.save(update_fields=["payment_link", "updated_at"])


class InitiateEscrowPaymentView(APIView):
    """
    POST /api/escrow/<id>/pay/
    Retry endpoint - only needed if Chapa initialization failed during
    create (e.g. sandbox keys not configured yet, or a transient error).
    """

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user != contract.buyer:
            return Response(
                {"error": "Only the buyer can initiate payment for this contract"},
                status=status.HTTP_403_FORBIDDEN,
            )
        if contract.status != EscrowContract.Status.PENDING_PAYMENT:
            return Response(
                {"error": f"Contract is not payable in status {contract.status}"},
                status=status.HTTP_409_CONFLICT,
            )

        _try_initiate_chapa_payment(request, contract)
        contract.refresh_from_db()

        if not contract.payment_link:
            return Response(
                {"error": "Could not reach Chapa - try again shortly"},
                status=status.HTTP_502_BAD_GATEWAY,
            )
        return Response({"payment_link": contract.payment_link})


class SandboxFundView(APIView):
    """
    POST /api/escrow/<id>/sandbox-fund/
    DEBUG only. Buyer marks a PENDING_PAYMENT contract as funded so
    local demos can continue when Chapa cannot webhook localhost.
    Uses record_escrow_funded() so the ledger stays balanced.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        if not settings.ALLOW_SANDBOX_FUND:
            return Response(
                {"error": "Sandbox funding is disabled on this server"},
                status=status.HTTP_403_FORBIDDEN,
            )
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user != contract.buyer:
            return Response(
                {"error": "Only the buyer can sandbox-fund this contract"},
                status=status.HTTP_403_FORBIDDEN,
            )
        if contract.status != EscrowContract.Status.PENDING_PAYMENT:
            return Response(
                {"error": f"Cannot sandbox-fund from status {contract.status}"},
                status=status.HTTP_409_CONFLICT,
            )

        payment_txn = (
            contract.payment_transactions.filter(
                direction=PaymentTransaction.Direction.INBOUND_FUNDING,
            )
            .order_by("-created_at")
            .first()
        )
        if payment_txn is None:
            payment_txn = PaymentTransaction.objects.create(
                escrow_contract=contract,
                provider=PaymentTransaction.Provider.MOCK,
                direction=PaymentTransaction.Direction.INBOUND_FUNDING,
                status=PaymentTransaction.Status.INITIATED,
                provider_tx_ref=f"sandbox-{contract.id}-{uuid.uuid4().hex[:8]}",
                amount=contract.amount,
                currency=contract.currency,
                raw_payload={"source": "sandbox-fund"},
            )

        if payment_txn.status != PaymentTransaction.Status.SUCCESS:
            payment_txn.status = PaymentTransaction.Status.SUCCESS
            payment_txn.raw_payload = {**payment_txn.raw_payload, "source": "sandbox-fund"}
            payment_txn.save(update_fields=["status", "raw_payload"])

        record_escrow_funded(contract, payment_txn)
        contract.refresh_from_db()
        return Response(EscrowContractSerializer(contract).data)


# 2. List my escrows

class MyEscrowContractsView(APIView):
    """
    GET /api/escrow/mine/
    Returns every contract the user is on, as buyer or seller.
    The Flutter shells split those into purchases vs sales.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        contracts = EscrowContract.objects.filter(
            models.Q(buyer=user) | models.Q(seller=user)
        )
        return Response(
            EscrowContractSerializer(
                contracts.order_by("-created_at"), many=True
            ).data
        )



# 3. Get one escrow

class EscrowDetailView(APIView):
    """GET /api/escrow/<id>/ - only the buyer or seller on it can view it."""

    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user not in (contract.buyer, contract.seller):
            return Response(
                {"error": "You do not have access to this contract"},
                status=status.HTTP_403_FORBIDDEN,
            )
        return Response(EscrowContractSerializer(contract).data)


#4. Mark shipped

class MarkShippedView(APIView):
    """POST /api/escrow/<id>/mark-shipped/ - seller only, FUNDED -> IN_TRANSIT."""

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user != contract.seller:
            return Response(
                {"error": "Only the seller can mark this contract as shipped"},
                status=status.HTTP_403_FORBIDDEN,
            )
        if contract.status != EscrowContract.Status.FUNDED:
            return Response(
                {"error": f"Cannot mark shipped from status {contract.status}"},
                status=status.HTTP_409_CONFLICT,
            )

        contract.status = EscrowContract.Status.IN_TRANSIT
        contract.save(update_fields=["status", "updated_at"])
        return Response(EscrowContractSerializer(contract).data)


# 5. Confirm delivery

class ConfirmDeliveryView(APIView):
    """
    POST /api/escrow/<id>/confirm-delivery/
    Buyer only. Accepts either qr_token or pin. Valid from FUNDED or
    IN_TRANSIT. Calls record_escrow_released(), which flips status to
    COMPLETED and posts the ledger entries atomically.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user != contract.buyer:
            return Response(
                {"error": "Only the buyer can confirm delivery"},
                status=status.HTTP_403_FORBIDDEN,
            )
        if contract.status not in (
            EscrowContract.Status.FUNDED,
            EscrowContract.Status.IN_TRANSIT,
        ):
            return Response(
                {"error": f"Cannot confirm delivery from status {contract.status}"},
                status=status.HTTP_409_CONFLICT,
            )

        serializer = ConfirmDeliverySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        verified = False
        if data.get("qr_token"):
            verified = str(data["qr_token"]) == str(contract.delivery_qr_token)
        elif data.get("pin"):
            verified = contract.check_verification_pin(data["pin"])

        if not verified:
            return Response(
                {"error": "QR token or PIN did not match"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        record_escrow_released(contract)
        contract.refresh_from_db()
        return Response(EscrowContractSerializer(contract).data)


# 6. Open dispute

class OpenDisputeView(APIView):
    """
    POST /api/escrow/<id>/dispute/
    Either party can open one. Allowed once funds are locked and before
    the contract is already completed/cancelled/disputed.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        contract = get_object_or_404(EscrowContract, pk=pk)
        if request.user not in (contract.buyer, contract.seller):
            return Response(
                {"error": "You do not have access to this contract"},
                status=status.HTTP_403_FORBIDDEN,
            )

        allowed_statuses = (
            EscrowContract.Status.FUNDED,
            EscrowContract.Status.IN_TRANSIT,
            EscrowContract.Status.DELIVERED_UNVERIFIED,
        )
        if contract.status not in allowed_statuses:
            return Response(
                {"error": f"Cannot open a dispute from status {contract.status}"},
                status=status.HTTP_409_CONFLICT,
            )
        if hasattr(contract, "dispute"):
            return Response(
                {"error": "A dispute already exists for this contract"},
                status=status.HTTP_409_CONFLICT,
            )

        serializer = DisputeCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        Dispute.objects.create(
            escrow=contract,
            opened_by=request.user,
            reason=serializer.validated_data["reason"],
        )
        contract.status = EscrowContract.Status.DISPUTED
        contract.save(update_fields=["status", "updated_at"])

        return Response(EscrowContractSerializer(contract).data, status=status.HTTP_201_CREATED)


# Chapa webhook listener (infrastructure needed for the flow to actually work)


class ChapaWebhookView(APIView):
    """
    POST /api/webhooks/chapa/
    Called by Chapa itself - no auth token. Trust is established purely
    via the HMAC signature check. Idempotent: replays of the same
    tx_ref are safely ignored, never double-credit the ledger.
    """

    permission_classes = [AllowAny]

    def post(self, request):
        signature = request.headers.get("Chapa-Signature", "")
        if not chapa.verify_webhook_signature(request.body, signature):
            return Response({"error": "Invalid signature"}, status=status.HTTP_401_UNAUTHORIZED)

        payload = request.data
        tx_ref = payload.get("tx_ref")
        payment_status = payload.get("status")

        try:
            payment_txn = PaymentTransaction.objects.select_related("escrow_contract").get(
                provider_tx_ref=tx_ref
            )
        except PaymentTransaction.DoesNotExist:
            return Response({"error": "Unknown tx_ref"}, status=status.HTTP_404_NOT_FOUND)

        if payment_txn.status == PaymentTransaction.Status.SUCCESS:
            return Response({"message": "Already processed"})

        payment_txn.raw_payload = payload

        if payment_status != "success":
            payment_txn.status = PaymentTransaction.Status.FAILED
            payment_txn.save(update_fields=["status", "raw_payload"])
            return Response({"message": "Recorded failed payment"})

        payment_txn.status = PaymentTransaction.Status.SUCCESS
        payment_txn.save(update_fields=["status", "raw_payload"])

        record_escrow_funded(payment_txn.escrow_contract, payment_txn)

        return Response({"message": "Escrow funded"})