"""Blood request persistence + the submit -> broadcast -> count orchestration."""

from __future__ import annotations

import logging
from typing import Any

from google.cloud import firestore

from app.config import settings
from app.firebase import get_db
from app.schemas import BloodRequestCreate, BloodRequestOut, BroadcastResult
from app.services import donors as donor_service
from app.services import fcm as fcm_service

logger = logging.getLogger(__name__)


class RequestNotFoundError(LookupError):
    pass


def _collection():
    return get_db().collection(settings.blood_requests_collection)


def _document_from_payload(payload: BloodRequestCreate) -> dict[str, Any]:
    return {
        "fullName": payload.full_name,
        "bloodGroup": payload.blood_group,
        "location": payload.location,
        "phoneNumber": payload.phone_number,
        "urgency": payload.urgency,
        "isUrgent": payload.urgency == "Urgent",
        "unitsNeeded": payload.units_needed,
        "note": payload.note,
        "requesterFcmToken": payload.requester_fcm_token,
        "status": "open",
        "createdAt": firestore.SERVER_TIMESTAMP,
    }


def create_request(payload: BloodRequestCreate) -> tuple[str, dict[str, Any]]:
    """Persist a request. Uses the client supplied id when there is one so the
    app can write first and the server stays idempotent."""
    document = _document_from_payload(payload)
    doc_ref = (
        _collection().document(payload.request_id)
        if payload.request_id
        else _collection().document()
    )
    doc_ref.set(document, merge=True)
    logger.info("Stored blood request %s (%s)", doc_ref.id, payload.blood_group)

    stored = doc_ref.get().to_dict() or document
    return doc_ref.id, stored


def get_request(request_id: str) -> dict[str, Any] | None:
    snapshot = _collection().document(request_id).get()
    if not snapshot.exists:
        return None
    return snapshot.to_dict() or {}


def list_requests(
    limit: int = 50,
    blood_group: str | None = None,
    status: str | None = "open",
) -> list[BloodRequestOut]:
    query = _collection()
    if blood_group:
        query = query.where(filter=firestore.FieldFilter("bloodGroup", "==", blood_group))
    if status:
        query = query.where(filter=firestore.FieldFilter("status", "==", status))
    query = query.order_by("createdAt", direction=firestore.Query.DESCENDING).limit(limit)

    return [to_out(snapshot.id, snapshot.to_dict() or {}) for snapshot in query.stream()]


def to_out(request_id: str, data: dict[str, Any]) -> BloodRequestOut:
    return BloodRequestOut(
        id=request_id,
        full_name=data.get("fullName") or "",
        blood_group=data.get("bloodGroup") or "",
        location=data.get("location") or "",
        phone_number=data.get("phoneNumber"),
        urgency=data.get("urgency") if data.get("urgency") in {"Urgent", "Not Urgent"} else "Not Urgent",
        units_needed=data.get("unitsNeeded"),
        note=data.get("note"),
        status=data.get("status") or "open",
        notified_count=int(data.get("notifiedCount") or 0),
        compatible_donor_count=int(data.get("compatibleDonorCount") or 0),
        created_at=data.get("createdAt"),
        notified_at=data.get("notifiedAt"),
    )


def _stored_result(request_id: str, data: dict[str, Any]) -> BroadcastResult:
    notified = int(data.get("notifiedCount") or 0)
    return BroadcastResult(
        request_id=request_id,
        notified_count=notified,
        total_registered_users=int(data.get("totalRegisteredUsers") or notified),
        compatible_donor_count=int(data.get("compatibleDonorCount") or 0),
        failed_count=int(data.get("failedCount") or 0),
        already_notified=True,
        message=_summary(notified, int(data.get("compatibleDonorCount") or 0)),
    )


def _summary(notified: int, compatible: int) -> str:
    if notified == 0:
        return (
            "Your request was saved, but no registered user has notifications "
            "enabled yet. Share it with donors you know."
        )
    people = "user" if notified == 1 else "users"
    text = f"Your request was sent to {notified} registered {people}."
    if compatible:
        donors_word = "donor" if compatible == 1 else "donors"
        text += f" {compatible} of them have a compatible blood group."
    return text


def submit_and_broadcast(
    payload: BloodRequestCreate,
    *,
    force: bool = False,
    dry_run: bool = False,
) -> BroadcastResult:
    """Save the request (if the app has not already) and push it to everyone."""
    request_id = payload.request_id
    stored: dict[str, Any] | None = get_request(request_id) if request_id else None

    if stored and stored.get("notifiedAt") and not force:
        logger.info("Request %s was already broadcast; returning stored counts", request_id)
        return _stored_result(request_id, stored)

    if stored:
        # The app wrote the document first - top it up with anything it missed.
        update = {k: v for k, v in _document_from_payload(payload).items() if v is not None}
        update.pop("createdAt", None)
        update.pop("status", None)
        _collection().document(request_id).set(update, merge=True)
        stored = {**stored, **update}
    else:
        request_id, stored = create_request(payload)

    audience = donor_service.fetch_audience(exclude_token=payload.requester_fcm_token)
    compatible = audience.compatible_count(payload.blood_group)

    stats = fcm_service.broadcast_blood_request(
        request_id=request_id,
        request=stored,
        tokens=audience.tokens,
        dry_run=dry_run,
    )

    if stats.invalid_tokens:
        donor_service.clear_invalid_tokens(audience.doc_ids_for(stats.invalid_tokens))

    _collection().document(request_id).set(
        {
            "notifiedCount": stats.success_count,
            "failedCount": stats.failure_count,
            "totalRegisteredUsers": len(audience.devices),
            "totalDonorProfiles": audience.total_documents,
            "compatibleDonorCount": compatible,
            "notificationStatus": _status(stats.success_count, stats.failure_count),
            "notifiedAt": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )

    return BroadcastResult(
        request_id=request_id,
        notified_count=stats.success_count,
        total_registered_users=len(audience.devices),
        compatible_donor_count=compatible,
        failed_count=stats.failure_count,
        already_notified=False,
        message=_summary(stats.success_count, compatible),
    )


def _status(success: int, failure: int) -> str:
    if success and failure:
        return "partial"
    if success:
        return "sent"
    if failure:
        return "failed"
    return "no_recipients"


def rebroadcast(request_id: str, *, dry_run: bool = False) -> BroadcastResult:
    """Re-send an existing request (e.g. it went out while donors were offline)."""
    stored = get_request(request_id)
    if stored is None:
        raise RequestNotFoundError(request_id)

    payload = BloodRequestCreate(
        request_id=request_id,
        full_name=stored.get("fullName") or "Unknown",
        blood_group=stored.get("bloodGroup") or "O+",
        location=stored.get("location") or "Unknown",
        phone_number=stored.get("phoneNumber"),
        urgency=stored.get("urgency") or "Not Urgent",
        units_needed=stored.get("unitsNeeded"),
        note=stored.get("note"),
        requester_fcm_token=stored.get("requesterFcmToken"),
    )
    return submit_and_broadcast(payload, force=True, dry_run=dry_run)


def close_request(request_id: str, status: str = "fulfilled") -> BloodRequestOut:
    doc_ref = _collection().document(request_id)
    if not doc_ref.get().exists:
        raise RequestNotFoundError(request_id)
    doc_ref.set({"status": status, "closedAt": firestore.SERVER_TIMESTAMP}, merge=True)
    return to_out(request_id, doc_ref.get().to_dict() or {})
