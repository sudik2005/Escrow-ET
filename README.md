# Escrow ET

## Description

Escrow ET is an API-driven, mobile-money-native escrow platform built for the Ethiopian e-commerce community. It acts as a trust layer between buyers and sellers who don't know each other — funds are held in escrow after payment and only released to the seller once the buyer confirms delivery, via a scanned QR code or PIN.

## Problem

In Ethiopian e-commerce, buyers and sellers who transact online have no reliable way to trust each other. Buyers risk paying and never receiving their item; sellers risk shipping and never getting paid. There's no neutral, automated way to guarantee both sides hold up their end of the deal — Escrow ET solves this by acting as a secure intermediary that only releases funds once delivery is verified.

## Main Features

- **Escrow contract engine** — tracks each transaction through a strict status flow: `PENDING_PAYMENT` → `FUNDED` → `IN_TRANSIT` → `DELIVERED_UNVERIFIED` → `COMPLETED`, with `DISPUTED` and `CANCELLED` as alternate paths
- **QR code delivery verification** — the buyer confirms receipt of their item by scanning a QR code, which is what triggers the release of funds to the seller
- **Double-entry ledger system** — every movement of money is recorded as a matched, permanent debit/credit pair, so all funds are fully auditable
- **Sandboxed payment integration** — built on top of Chapa's test/sandbox API, simulating real payment flows without custodying real money
- **Dispute resolution system** — buyers or sellers can open a dispute with a reason and supporting evidence, resolved by an admin (refund or release)
- **Merchant API** — allows external e-commerce sites to integrate Escrow ET into their own checkout flow via public/secret API keys and webhooks

## Team Members

| Full Name | CTC Number |
|---|---|
| Hermela Mezgebu | CTC-3629-26 |
| Kalkidan Asdro | CTC-3081-26 |
| Kidus Mintesnot | CTC-5088-26 |
| Kokebe Aschalew | CTC-3609-26 |
| Mading Majok | CTC-7620-26 |

## Classroom Number

3004