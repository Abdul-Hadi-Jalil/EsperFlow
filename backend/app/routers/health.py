"""Liveness / readiness endpoints."""

from __future__ import annotations

import logging

from fastapi import APIRouter

from app import __version__
from app.config import settings
from app.firebase import get_app

logger = logging.getLogger(__name__)

router = APIRouter(tags=["health"])


@router.get("/health")
def health() -> dict:
    """Cheap liveness probe - does not touch Firebase."""
    return {"status": "ok", "service": "esperflow-backend", "version": __version__}


@router.get("/ready")
def ready() -> dict:
    """Readiness probe.

    Mints an access token so a missing service account is reported here rather
    than surfacing later as a failed broadcast.
    """
    try:
        app = get_app()
        app.credential.get_access_token()
        return {
            "status": "ok",
            "projectId": app.project_id or settings.firebase_project_id,
            "firebase": "connected",
        }
    except Exception as exc:  # noqa: BLE001 - reported, not raised, so probes read it
        logger.exception("Firebase credentials are not usable")
        return {"status": "degraded", "firebase": "unavailable", "detail": str(exc)}
