"""
Parse and verify Ethiopian Fayda ID card QR payloads (V4).

Offline decoder ported from the community fayda-decoder spec. The RS256
public key is pinned from NIDP's scanner at https://id.et/scanId.
This is card-possession plus signature check, not an official NIDP API.
"""

from __future__ import annotations

import base64
import json
import re
from dataclasses import dataclass
from datetime import date, datetime, timezone

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPublicKey

# Provenance: recovered from https://id.et/scanId (observed 2026-08-16).
# SPKI SHA-256: 803dcd26057edc1423a5b9655f03c945b84a146be28caa754bc460a3fea6624a
FAYDA_V4_PUBLIC_KEY_PEM = b"""-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxMWfApFZBq/qIotUjrkY
bdyXQcHOUgZsqZy3QUcXr50t+DfwYKkSfMnTZFHekptAWA4HM5upav6xqFuP+3Pi
KmajY2Imkl60bF4Bt9qcch74jPSObH/1CE0xs75dqLb+CfoTG1+i4n3Fz5cN9Mxp
EGE7pmvIdYtaAUCoKA/cjQ5QY426ttp4EQcnh5vmyr1e7ur9LjqVVsurfefxlsR+
sRfB2RFuaEGrLO/75UeUSY2x1nTHzOvycWYaCve1YfunHkXA8JvUy73+b33ixIgw
QuqUkOuyKhytFr5l6N1gfjTvOOysclCH5o8jy7KyzgyK17kHXPAaKuxYXH9pGtAF
0wIDAQAB
-----END PUBLIC KEY-----"""

_SUPPORTED_VERSIONS = {"4"}
_FAN_RE = re.compile(r"^\d{10,20}$")
_DOB_RE = re.compile(r"^(\d{4})/(\d{2})/(\d{2})$")


class FaydaError(Exception):
    def __init__(self, code: str, message: str):
        self.code = code
        super().__init__(message)


@dataclass(frozen=True)
class FaydaIdentity:
    full_name: str
    gender: str | None
    fan: str
    date_of_birth: date | None
    payload_version: str


@dataclass(frozen=True)
class _ParsedPayload:
    full_name: str
    gender: str | None
    fan: str | None
    date_of_birth: date | None
    payload_version: str
    raw_payload: str
    jws: str


def verify_and_decode(raw_payload: str) -> FaydaIdentity:
    parsed = _decode_payload(raw_payload)
    _verify_signature(parsed)
    if not parsed.fan:
        raise FaydaError(
            "MISSING_FAN",
            "The Fayda QR did not include a valid Fayda number.",
        )
    return FaydaIdentity(
        full_name=parsed.full_name,
        gender=parsed.gender,
        fan=parsed.fan,
        date_of_birth=parsed.date_of_birth,
        payload_version=parsed.payload_version,
    )


def _decode_payload(text: str) -> _ParsedPayload:
    payload = (text or "").strip()
    if ":DLT:" not in payload or ":SIGN:" not in payload:
        raise FaydaError(
            "NOT_FAYDA",
            "The QR payload is not a recognizable Fayda ID structure.",
        )

    dlt_idx = payload.index(":DLT:")
    rest = payload[dlt_idx + len(":DLT:") :]
    sign_idx = rest.find(":SIGN:")
    if sign_idx == -1:
        raise FaydaError(
            "NOT_FAYDA",
            "The QR payload is not a recognizable Fayda ID structure.",
        )

    fields_part = rest[:sign_idx]
    jws = rest[sign_idx + len(":SIGN:") :]
    segments = fields_part.split(":")
    full_name = segments[0].strip() if segments else ""
    if not full_name:
        raise FaydaError(
            "NOT_FAYDA",
            "The QR payload is not a recognizable Fayda ID structure.",
        )

    raw_map: dict[str, str] = {}
    tail = segments[1:]
    for i in range(0, len(tail) - 1, 2):
        raw_map[tail[i]] = tail[i + 1]

    version = raw_map.get("V")
    if version not in _SUPPORTED_VERSIONS:
        raise FaydaError(
            "UNSUPPORTED_VERSION",
            f"Unsupported Fayda payload version: {version}.",
        )

    return _ParsedPayload(
        full_name=full_name,
        gender=_parse_gender(raw_map.get("G")),
        fan=_parse_fan(raw_map.get("A")),
        date_of_birth=_parse_dob(raw_map.get("D")),
        payload_version=version,
        raw_payload=payload,
        jws=jws,
    )


def _verify_signature(
    parsed: _ParsedPayload,
    *,
    public_key_pem: bytes | None = None,
) -> None:
    jws = parsed.jws
    if not jws:
        raise FaydaError("SIGNATURE_MISSING", "The Fayda QR is missing a signature.")
    if parsed.payload_version != "4" and public_key_pem is None:
        raise FaydaError(
            "UNSUPPORTED_VERSION",
            f"Unsupported Fayda payload version: {parsed.payload_version}.",
        )

    parts = jws.split(".")
    if len(parts) != 3 or parts[0] == "" or parts[1] != "" or parts[2] == "":
        raise FaydaError("MALFORMED_JWS", "The Fayda QR signature is malformed.")

    try:
        header = json.loads(_b64url_decode(parts[0]))
    except (ValueError, json.JSONDecodeError) as exc:
        raise FaydaError("MALFORMED_JWS", "The Fayda QR signature is malformed.") from exc
    if not isinstance(header, dict) or header.get("alg") != "RS256":
        raise FaydaError(
            "UNSUPPORTED_ALGORITHM",
            "The Fayda QR uses an unsupported signature algorithm.",
        )

    marker = parsed.raw_payload.rfind(":SIGN:")
    if marker == -1:
        raise FaydaError("MALFORMED_JWS", "The Fayda QR signature is malformed.")

    detached = parsed.raw_payload[:marker]
    signing_input = f"{parts[0]}.{_b64url_encode(detached.encode('utf-8'))}".encode("utf-8")
    try:
        signature = _b64url_decode(parts[2])
    except ValueError as exc:
        raise FaydaError("MALFORMED_JWS", "The Fayda QR signature is malformed.") from exc

    key = serialization.load_pem_public_key(public_key_pem or FAYDA_V4_PUBLIC_KEY_PEM)
    if not isinstance(key, RSAPublicKey):
        raise FaydaError("INVALID_SIGNATURE", "This Fayda QR signature is not valid.")
    try:
        key.verify(signature, signing_input, padding.PKCS1v15(), hashes.SHA256())
    except (InvalidSignature, ValueError) as exc:
        raise FaydaError(
            "INVALID_SIGNATURE",
            "This Fayda QR signature is not valid.",
        ) from exc


def _parse_gender(value: str | None) -> str | None:
    return value if value in ("M", "F") else None


def _parse_fan(value: str | None) -> str | None:
    if value is None:
        return None
    return value if _FAN_RE.match(value) else None


def _parse_dob(value: str | None) -> date | None:
    if value is None:
        return None
    match = _DOB_RE.match(value)
    if not match:
        return None
    year, month, day = (int(match.group(1)), int(match.group(2)), int(match.group(3)))
    try:
        parsed = datetime(year, month, day, tzinfo=timezone.utc).date()
    except ValueError:
        return None
    return parsed


def _b64url_decode(data: str) -> bytes:
    pad = "=" * ((4 - len(data) % 4) % 4)
    return base64.urlsafe_b64decode(data + pad)


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")
