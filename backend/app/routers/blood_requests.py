"""Blood request API.

The Flutter app writes the request to Firestore, then POSTs here; this router
fans it out to every registered user over FCM and answers with how many people
were reached.
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.blood_groups import normalize
from app.dependencies import verify_api_key
from app.schemas import (
    BloodRequestCreate,
    BloodRequestOut,
    BroadcastResult,
    DonorReachOut,
    TokenStatusIn,
    TokenStatusOut,
)
from app.services import blood_requests as service
from app.services import donors as donor_service
from app.services import fcm as fcm_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["blood-requests"])


@router.post(
    "/blood-requests",
    response_model=BroadcastResult,
    status_code=status.HTTP_201_CREATED,
    summary="Broadcast a blood request to every registered user",
)
def submit_blood_request(
    payload: BloodRequestCreate,
    dry_run: bool = Query(default=False, alias="dryRun"),
    _: None = Depends(verify_api_key),
) -> BroadcastResult:
    """Saves the request when the app has not already, sends the push to all
    registered devices, and returns the donor reach counts for the UI."""
    try:
        return service.submit_and_broadcast(payload, dry_run=dry_run)
    except Exception as exc:  # noqa: BLE001 - mapped to a clean 502 for the app
        logger.exception("Failed to broadcast blood request")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Could not broadcast the request: {exc}",
        ) from exc


@router.get(
    "/blood-requests",
    response_model=list[BloodRequestOut],
    summary="List blood requests, newest first",
)
def list_blood_requests(
    limit: int = Query(default=50, ge=1, le=200),
    blood_group: str | None = Query(default=None, alias="bloodGroup"),
    status_filter: str | None = Query(default="open", alias="status"),
) -> list[BloodRequestOut]:
    group = normalize(blood_group) if blood_group else None
    if blood_group and group is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown blood group.")
    try:
        return service.list_requests(
            limit=limit,
            blood_group=group,
            status=None if status_filter in {None, "", "all"} else status_filter,
        )
    except Exception as exc:  # noqa: BLE001
        logger.exception("Failed to list blood requests")
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(exc)) from exc


@router.get(
    "/blood-requests/{request_id}",
    response_model=BloodRequestOut,
    summary="Fetch one request, including how many users it reached",
)
def get_blood_request(request_id: str) -> BloodRequestOut:
    data = service.get_request(request_id)
    if data is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Blood request not found.")
    return service.to_out(request_id, data)


@router.post(
    "/blood-requests/{request_id}/notify",
    response_model=BroadcastResult,
    summary="Re-send an existing request to every registered user",
)
def rebroadcast_blood_request(
    request_id: str,
    dry_run: bool = Query(default=False, alias="dryRun"),
    _: None = Depends(verify_api_key),
) -> BroadcastResult:
    try:
        return service.rebroadcast(request_id, dry_run=dry_run)
    except service.RequestNotFoundError as exc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Blood request not found.") from exc
    except Exception as exc:  # noqa: BLE001
        logger.exception("Failed to re-broadcast %s", request_id)
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(exc)) from exc


@router.post(
    "/blood-requests/{request_id}/close",
    response_model=BloodRequestOut,
    summary="Mark a request fulfilled or cancelled",
)
def close_blood_request(
    request_id: str,
    new_status: str = Query(default="fulfilled", alias="status"),
    _: None = Depends(verify_api_key),
) -> BloodRequestOut:
    if new_status not in {"fulfilled", "cancelled", "expired"}:
        raise HTTPException(
            status.HTTP_400_BAD_REQUEST,
            "status must be fulfilled, cancelled or expired.",
        )
    try:
        return service.close_request(request_id, new_status)
    except service.RequestNotFoundError as exc:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Blood request not found.") from exc


@router.post(
    "/donors/verify-token",
    response_model=TokenStatusOut,
    summary="Check whether a device's push token is still live",
)
def verify_donor_token(
    payload: TokenStatusIn,
    _: None = Depends(verify_api_key),
) -> TokenStatusOut:
    """Lets the app detect a token FCM has retired before storing it, so a
    donor never registers as unreachable. Delivers no notification."""
    try:
        valid, reason = fcm_service.is_token_deliverable(payload.token)
    except Exception as exc:  # noqa: BLE001
        logger.exception("Token verification failed")
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(exc)) from exc
    return TokenStatusOut(valid=valid, reason=reason)


@router.get(
    "/donors/reach",
    response_model=DonorReachOut,
    summary="How many registered users a request would reach",
)
def donor_reach(
    blood_group: str | None = Query(default=None, alias="bloodGroup"),
) -> DonorReachOut:
    group = normalize(blood_group) if blood_group else None
    if blood_group and group is None:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Unknown blood group.")
    try:
        audience = donor_service.fetch_audience()
    except Exception as exc:  # noqa: BLE001
        logger.exception("Failed to read the donor audience")
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(exc)) from exc

    return DonorReachOut(
        total_registered_users=audience.total_documents,
        reachable_devices=len(audience.devices),
        compatible_donor_count=audience.compatible_count(group) if group else 0,
        blood_group=group,
    )
