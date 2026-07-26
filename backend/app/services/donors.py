"""Reading the audience of a blood request out of Firestore.

"Registered users" are the documents the Donate Blood screen writes to the
`donors` collection. A device is reachable only if that document carries an FCM
token, and the same physical device can appear under several documents (the app
generates a fresh uuid on every submit), so tokens are de-duplicated here.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from google.cloud import firestore

from app.blood_groups import can_donate_to, normalize
from app.config import settings
from app.firebase import get_db

logger = logging.getLogger(__name__)

_FIRESTORE_BATCH_LIMIT = 500
_SELECTED_FIELDS = ["fcmToken", "bloodGroup", "activeDonorStatus", "registeredAt"]


@dataclass(frozen=True)
class DonorDevice:
    """One reachable device, plus every donor document that points at it."""

    token: str
    blood_group: str | None
    active: bool
    doc_ids: tuple[str, ...]


@dataclass
class DonorAudience:
    devices: list[DonorDevice] = field(default_factory=list)
    total_documents: int = 0
    excluded_requester_devices: int = 0

    @property
    def tokens(self) -> list[str]:
        return [device.token for device in self.devices]

    def compatible_count(self, recipient_blood_group: str | None) -> int:
        return sum(
            1
            for device in self.devices
            if can_donate_to(device.blood_group, recipient_blood_group)
        )

    def doc_ids_for(self, tokens: set[str]) -> list[str]:
        return [
            doc_id
            for device in self.devices
            if device.token in tokens
            for doc_id in device.doc_ids
        ]


def _registered_at(data: dict) -> float:
    registered_at = data.get("registeredAt")
    try:
        return registered_at.timestamp()  # type: ignore[union-attr]
    except AttributeError:
        return 0.0


def fetch_audience(exclude_token: str | None = None) -> DonorAudience:
    """Every registered donor device, newest registration winning per token."""
    collection = get_db().collection(settings.donors_collection)
    records = [
        (snapshot.id, snapshot.to_dict() or {})
        for snapshot in collection.select(_SELECTED_FIELDS).stream()
    ]

    # Newest first so the freshest blood group / status wins for a repeated token.
    records.sort(key=lambda record: _registered_at(record[1]), reverse=True)

    audience = DonorAudience(total_documents=len(records))
    by_token: dict[str, dict] = {}

    for doc_id, data in records:
        token = str(data.get("fcmToken") or "").strip()
        if not token:
            continue
        if exclude_token and token == exclude_token:
            audience.excluded_requester_devices += 1
            continue

        entry = by_token.get(token)
        if entry is None:
            by_token[token] = {
                "blood_group": normalize(data.get("bloodGroup")),
                "active": bool(data.get("activeDonorStatus", True)),
                "doc_ids": [doc_id],
            }
        else:
            entry["doc_ids"].append(doc_id)

    for token, entry in by_token.items():
        if settings.notify_only_active_donors and not entry["active"]:
            continue
        audience.devices.append(
            DonorDevice(
                token=token,
                blood_group=entry["blood_group"],
                active=entry["active"],
                doc_ids=tuple(entry["doc_ids"]),
            )
        )

    logger.info(
        "Audience: %s donor documents, %s reachable devices",
        audience.total_documents,
        len(audience.devices),
    )
    return audience


def clear_invalid_tokens(doc_ids: list[str]) -> int:
    """Drop tokens FCM rejected so the next broadcast does not retry them."""
    if not doc_ids:
        return 0

    db = get_db()
    collection = db.collection(settings.donors_collection)
    cleared = 0

    for start in range(0, len(doc_ids), _FIRESTORE_BATCH_LIMIT):
        chunk = doc_ids[start : start + _FIRESTORE_BATCH_LIMIT]
        batch = db.batch()
        for doc_id in chunk:
            batch.update(
                collection.document(doc_id),
                {
                    "fcmToken": firestore.DELETE_FIELD,
                    "tokenInvalidatedAt": firestore.SERVER_TIMESTAMP,
                },
            )
        try:
            batch.commit()
            cleared += len(chunk)
        except Exception:  # noqa: BLE001 - cleanup must never fail the broadcast
            logger.exception("Failed to clear %s stale donor tokens", len(chunk))

    if cleared:
        logger.info("Cleared %s stale donor token(s)", cleared)
    return cleared
