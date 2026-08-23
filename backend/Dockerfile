# Stage 1: install dependencies
FROM python:3.12-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2: runtime image
FROM python:3.12-slim AS runtime

WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

COPY . .

# Collect static files; dummy secrets are safe here — no DB query is executed
RUN DJANGO_SECRET_KEY=dummy-build-key \
    DATABASE_URL=postgres://x:x@localhost/x \
    python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "escrow_backend.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "2", \
     "--timeout", "60"]
