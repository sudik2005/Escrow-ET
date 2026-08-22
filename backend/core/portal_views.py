from decimal import Decimal

from django.db.models import Q, Sum
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .merchant import can_create_escrow, generate_merchant_keys, get_or_create_merchant_settings
from .notify import notify_merchant_webhook
from .models import (
    Dispute,
    DisputeMessage,
    EscrowContract,
    User,
    record_escrow_refunded,
    record_escrow_released,
)
from .serializers import (
    DisputeMessageSerializer,
    DisputeSerializer,
    MerchantSettingsSerializer,
)


def _is_admin(user):
    return user.role == User.Role.ADMIN


def _can_see_dispute(user, dispute: Dispute) -> bool:
    if _is_admin(user):
        return True
    return user in (
        dispute.opened_by,
        dispute.escrow.buyer,
        dispute.escrow.seller,
    )


def _dispute_queryset(user):
    qs = Dispute.objects.select_related(
        "escrow",
        "escrow__buyer",
        "escrow__seller",
        "opened_by",
    ).prefetch_related("messages__sender")
    if _is_admin(user):
        return qs
    return qs.filter(
        Q(opened_by=user) | Q(escrow__buyer=user) | Q(escrow__seller=user)
    )


class MerchantSettingsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not can_create_escrow(request.user):
            return Response(
                {"error": "Only sellers and merchants have API keys"},
                status=status.HTTP_403_FORBIDDEN,
            )
        settings_obj = get_or_create_merchant_settings(request.user)
        return Response(MerchantSettingsSerializer(settings_obj).data)

    def patch(self, request):
        if not can_create_escrow(request.user):
            return Response(
                {"error": "Only sellers and merchants have API keys"},
                status=status.HTTP_403_FORBIDDEN,
            )
        settings_obj = get_or_create_merchant_settings(request.user)
        serializer = MerchantSettingsSerializer(
            settings_obj,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(MerchantSettingsSerializer(settings_obj).data)


class MerchantSettingsRotateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if not can_create_escrow(request.user):
            return Response(
                {"error": "Only sellers and merchants have API keys"},
                status=status.HTTP_403_FORBIDDEN,
            )
        settings_obj = get_or_create_merchant_settings(request.user)
        public_key, secret_key = generate_merchant_keys()
        settings_obj.public_key = public_key
        settings_obj.secret_key = secret_key
        settings_obj.save(update_fields=["public_key", "secret_key"])
        return Response(MerchantSettingsSerializer(settings_obj).data)


class DisputeListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        disputes = _dispute_queryset(request.user).order_by("-created_at")
        return Response(DisputeSerializer(disputes, many=True).data)


class DisputeDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        dispute = get_object_or_404(
            Dispute.objects.select_related(
                "escrow",
                "escrow__buyer",
                "escrow__seller",
                "opened_by",
            ).prefetch_related("messages__sender"),
            pk=pk,
        )
        if not _can_see_dispute(request.user, dispute):
            return Response(
                {"error": "You do not have access to this dispute"},
                status=status.HTTP_403_FORBIDDEN,
            )
        return Response(DisputeSerializer(dispute).data)


class DisputeMessageCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        dispute = get_object_or_404(
            Dispute.objects.select_related("escrow", "opened_by"),
            pk=pk,
        )
        if not _can_see_dispute(request.user, dispute):
            return Response(
                {"error": "You do not have access to this dispute"},
                status=status.HTTP_403_FORBIDDEN,
            )
        text = (request.data.get("message") or "").strip()
        attachment_url = (request.data.get("attachment_url") or "").strip() or None
        if not text and not attachment_url:
            return Response(
                {"error": "Message cannot be empty"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not text:
            text = "Attachment"
        msg = DisputeMessage.objects.create(
            dispute=dispute,
            sender=request.user,
            message=text,
            attachment_url=attachment_url,
        )
        return Response(DisputeMessageSerializer(msg).data, status=status.HTTP_201_CREATED)


class DisputeReviewView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        if not _is_admin(request.user):
            return Response(
                {"error": "Only admins can review disputes"},
                status=status.HTTP_403_FORBIDDEN,
            )
        dispute = get_object_or_404(Dispute, pk=pk)
        if dispute.status not in (Dispute.Status.OPEN, Dispute.Status.UNDER_REVIEW):
            return Response(
                {"error": f"Cannot review a dispute in status {dispute.status}"},
                status=status.HTTP_409_CONFLICT,
            )
        dispute.status = Dispute.Status.UNDER_REVIEW
        dispute.save(update_fields=["status"])
        return Response(DisputeSerializer(dispute).data)


class DisputeResolveView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, pk):
        if not _is_admin(request.user):
            return Response(
                {"error": "Only admins can resolve disputes"},
                status=status.HTTP_403_FORBIDDEN,
            )
        dispute = get_object_or_404(
            Dispute.objects.select_related("escrow", "escrow__buyer", "escrow__seller"),
            pk=pk,
        )
        if dispute.status in (
            Dispute.Status.RESOLVED_RELEASED,
            Dispute.Status.RESOLVED_REFUNDED,
        ):
            return Response(
                {"error": "This dispute is already resolved"},
                status=status.HTTP_409_CONFLICT,
            )
        resolution = (request.data.get("resolution") or "").strip().lower()
        if resolution not in ("release", "refund"):
            return Response(
                {"error": "resolution must be release or refund"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if dispute.escrow.status != EscrowContract.Status.DISPUTED:
            return Response(
                {"error": f"Escrow is not disputed ({dispute.escrow.status})"},
                status=status.HTTP_409_CONFLICT,
            )
        if resolution == "release":
            record_escrow_released(dispute.escrow)
            dispute.status = Dispute.Status.RESOLVED_RELEASED
            event = "escrow.released"
        else:
            record_escrow_refunded(dispute.escrow)
            dispute.status = Dispute.Status.RESOLVED_REFUNDED
            event = "escrow.refunded"
        dispute.save(update_fields=["status"])
        dispute.escrow.refresh_from_db()
        notify_merchant_webhook(dispute.escrow, event)
        dispute.refresh_from_db()
        return Response(DisputeSerializer(dispute).data)


class AdminOverviewView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if not _is_admin(request.user):
            return Response(
                {"error": "Only admins can view this overview"},
                status=status.HTTP_403_FORBIDDEN,
            )
        locked_statuses = (
            EscrowContract.Status.FUNDED,
            EscrowContract.Status.IN_TRANSIT,
            EscrowContract.Status.DELIVERED_UNVERIFIED,
            EscrowContract.Status.DISPUTED,
        )
        locked = EscrowContract.objects.filter(status__in=locked_statuses).aggregate(
            total=Sum("amount")
        )["total"] or Decimal("0.00")
        released = EscrowContract.objects.filter(
            status=EscrowContract.Status.COMPLETED
        ).aggregate(total=Sum("amount"))["total"] or Decimal("0.00")
        return Response(
            {
                "total_transactions": EscrowContract.objects.count(),
                "total_locked": str(locked),
                "total_released": str(released),
                "open_disputes": Dispute.objects.exclude(
                    status__in=(
                        Dispute.Status.RESOLVED_RELEASED,
                        Dispute.Status.RESOLVED_REFUNDED,
                    )
                ).count(),
            }
        )
