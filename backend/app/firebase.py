"""Lazy Firebase Admin bootstrap.

The Admin SDK is the *trusted* half of Cloud Messaging: it is the only thing
allowed to actually deliver a push to the tokens the app collects.
"""

from __future__ import annotations

import base64
import binascii
import json
import logging
from functools import lru_cache
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore, messaging
from google.cloud.firestore_v1.client import Client as FirestoreClient

from app.config import settings

logger = logging.getLogger(__name__)

_CREDENTIALS_HELP = (
    "No Firebase Admin credentials found. In the Firebase console open "
    "Project settings > Service accounts > Generate new private key, then either "
    "save the file as backend/serviceAccountKey.json (or point "
    "FIREBASE_SERVICE_ACCOUNT_PATH at it) or paste its contents into "
    "FIREBASE_SERVICE_ACCOUNT_JSON."
)


class CredentialsError(RuntimeError):
    """Raised when the service account cannot be located or parsed."""


def _credentials_from_json(raw: str) -> credentials.Base:
    """Accept either raw JSON or a base64 blob (easier to paste into a host)."""
    text = raw.strip()
    if not text.startswith("{"):
        try:
            text = base64.b64decode(text, validate=True).decode("utf-8")
        except (binascii.Error, UnicodeDecodeError) as exc:
            raise CredentialsError(
                "FIREBASE_SERVICE_ACCOUNT_JSON is neither valid JSON nor base64."
            ) from exc
    try:
        return credentials.Certificate(json.loads(text))
    except (json.JSONDecodeError, ValueError) as exc:
        raise CredentialsError(f"FIREBASE_SERVICE_ACCOUNT_JSON is invalid: {exc}") from exc


def _resolve_credentials() -> credentials.Base:
    if settings.firebase_service_account_json:
        logger.info("Using Firebase credentials from FIREBASE_SERVICE_ACCOUNT_JSON")
        return _credentials_from_json(settings.firebase_service_account_json)

    if settings.firebase_service_account_path:
        path = Path(settings.firebase_service_account_path).expanduser()
        if not path.is_absolute():
            path = (Path(__file__).resolve().parent.parent / path).resolve()
        if path.is_file():
            logger.info("Using Firebase credentials from %s", path)
            return credentials.Certificate(str(path))

    # Cloud Run / GCE / gcloud auth application-default login
    try:
        logger.info("Falling back to application default credentials")
        default_credentials = credentials.ApplicationDefault()
        # ApplicationDefault resolves lazily, so constructing it always succeeds
        # even with no credentials anywhere. Force the lookup now: otherwise a
        # missing key looks like a healthy boot and only surfaces later as a
        # failed broadcast, long after the cause is obvious.
        default_credentials.get_credential()
        return default_credentials
    except Exception as exc:  # noqa: BLE001 - surfaced as a readable startup error
        raise CredentialsError(f"{_CREDENTIALS_HELP} (underlying error: {exc})") from exc


@lru_cache
def get_app() -> firebase_admin.App:
    """Initialise (once) and return the Firebase Admin app."""
    if firebase_admin._apps:  # noqa: SLF001 - the SDK exposes no public accessor
        return firebase_admin.get_app()
    return firebase_admin.initialize_app(
        _resolve_credentials(),
        {"projectId": settings.firebase_project_id},
    )


def get_db() -> FirestoreClient:
    """Firestore client bound to the EsperFlow project."""
    return firestore.client(app=get_app())


def get_messaging():
    """The firebase_admin.messaging module, with the app guaranteed initialised."""
    get_app()
    return messaging
