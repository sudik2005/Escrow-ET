# Escrow ET

API-driven, mobile-money-native escrow for Ethiopian e-commerce (INSA Cyber Talent Center Summer Camp, Group 6).

A buyer pays into escrow, the seller ships, and funds release only after the buyer confirms delivery (QR or PIN).

## Stack

- Mobile: Flutter
- Web dashboards: React
- API: Django REST Framework
- Database: SQLite for the camp build (Supabase / PostgreSQL later)
- Payments: Chapa sandbox only — no live keys, no real money

This project is the escrow engine that would sit on top of a licensed payment-service-provider partnership. It does not custody customer funds.

## Repo workflow

- Default branch: `main` (protected). Work on a branch, then open a pull request.
- Branch prefixes: `ui/`, `feat/`, `api/`, `models/`, `fix/`
- Direct pushes and force pushes to `main` are blocked.

## Team domains

- Flutter (mobile)
- React (web)
- Django (API and ledger)
