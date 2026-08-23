from django.urls import path
from . import portal_views, views

urlpatterns = [
    # --- Auth (Fayda QR register/login; password login kept for existing users) ---
    path("auth/register/", views.RegisterView.as_view(), name="register"),
    path("auth/login/", views.LoginView.as_view(), name="login"),
    path("auth/logout/", views.LogoutView.as_view(), name="logout"),
    path("auth/me/", views.MeView.as_view(), name="me"),

    # --- Escrow, in the order Kidus asked for ---
    path("escrow/create/", views.EscrowCreateView.as_view(), name="escrow-create"),
    path("escrow/mine/", views.MyEscrowContractsView.as_view(), name="escrow-mine"),
    path("escrow/<uuid:pk>/", views.EscrowDetailView.as_view(), name="escrow-detail"),
    path("escrow/<uuid:pk>/mark-shipped/", views.MarkShippedView.as_view(), name="escrow-mark-shipped"),
    path("escrow/<uuid:pk>/confirm-delivery/", views.ConfirmDeliveryView.as_view(), name="escrow-confirm-delivery"),
    path("escrow/<uuid:pk>/dispute/", views.OpenDisputeView.as_view(), name="escrow-dispute"),

    # --- Supporting infrastructure ---
    path("escrow/<uuid:pk>/pay/", views.InitiateEscrowPaymentView.as_view(), name="escrow-pay"),
    path("escrow/<uuid:pk>/sandbox-fund/", views.SandboxFundView.as_view(), name="escrow-sandbox-fund"),
    path("webhooks/chapa/", views.ChapaWebhookView.as_view(), name="chapa-webhook"),

    # --- Merchant keys, disputes, admin ---
    path("merchant/settings/", portal_views.MerchantSettingsView.as_view(), name="merchant-settings"),
    path("merchant/settings/rotate/", portal_views.MerchantSettingsRotateView.as_view(), name="merchant-settings-rotate"),
    path("disputes/", portal_views.DisputeListView.as_view(), name="dispute-list"),
    path("disputes/<uuid:pk>/", portal_views.DisputeDetailView.as_view(), name="dispute-detail"),
    path("disputes/<uuid:pk>/messages/", portal_views.DisputeMessageCreateView.as_view(), name="dispute-messages"),
    path("disputes/<uuid:pk>/review/", portal_views.DisputeReviewView.as_view(), name="dispute-review"),
    path("disputes/<uuid:pk>/resolve/", portal_views.DisputeResolveView.as_view(), name="dispute-resolve"),
    path("admin/overview/", portal_views.AdminOverviewView.as_view(), name="admin-overview"),
]