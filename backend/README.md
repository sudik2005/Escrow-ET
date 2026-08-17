# backend

Django REST API (Chapa webhooks, ledger, Swagger).

Database: **Supabase PostgreSQL** via `DATABASE_URL`. No SQLite.

```
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Copy `.env.example` to `.env` (or use the repo-root `.env`) and set `DATABASE_URL`.
