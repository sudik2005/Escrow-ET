from django.urls import path
from . import views

urlpatterns = [
    # --- Auth (unchanged - field names untouched per Kidus's note) ---
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
    path("webhooks/chapa/", views.ChapaWebhookView.as_view(), name="chapa-webhook"),
]