import os

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "escrow_backend.settings")

from escrow_backend.wsgi import application as app  # noqa: E402
