# mobile

Flutter app for Escrow ET (buyer/seller dashboards, QR delivery verification).

This is a JSON client of the Django API. It does not connect to the database.

UI follows the shared Escrow ET design (deep red `#C00000`, Geist / Hanken Grotesk, light/dark) so it matches the web portal.

```
cd mobile
flutter pub get
flutter run
```

The app talks to the Django REST API:

- `POST /api/auth/register/`
- `POST /api/auth/login/`
- `GET /api/auth/me/`
- `POST /api/auth/logout/`
- `POST /api/escrow/create/`
- `GET /api/escrow/mine/`
- `POST /api/escrow/<id>/confirm-delivery/`

Default API URL is `http://127.0.0.1:8000/api` (Android emulator uses `http://10.0.2.2:8000/api`). Override with:

```
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api
```

Start Django first (`cd backend` then `python manage.py runserver`). If you use the Android emulator, add `10.0.2.2` to `DJANGO_ALLOWED_HOSTS`.
