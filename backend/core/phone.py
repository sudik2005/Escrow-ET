"""Normalize Ethiopian phone numbers to +2519xxxxxxxx."""

from __future__ import annotations

import re

_NON_DIGIT = re.compile(r"\D")


def normalize_et_phone(value: str) -> str:
    raw = (value or "").strip()
    digits = _NON_DIGIT.sub("", raw)
    if digits.startswith("251") and len(digits) >= 12:
        local = digits[3:]
    elif digits.startswith("0"):
        local = digits[1:]
    else:
        local = digits
    if len(local) == 9:
        return f"+251{local}"
    return raw
