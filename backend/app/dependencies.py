"""Shared FastAPI dependencies."""

from __future__ import annotations

import hmac

from fastapi import Header, HTTPException, status

from app.config import settings


def verify_api_key(x_api_key: str | None = Header(default=None)) -> None:
    """Guard the write endpoints with a shared secret.

    Skipped entirely when API_KEY is unset so local development stays friction
    free, but it should always be set for a deployed server - anyone who can
    reach POST /api/blood-requests can push a notification to every user.
    """
    if not settings.api_key:
        return
    if not x_api_key or not hmac.compare_digest(x_api_key, settings.api_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing x-api-key header.",
        )
