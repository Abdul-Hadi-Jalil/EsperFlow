"""The trusted sender: turns a blood request into a push for every device."""

from __future__ import annotations

import logging
from dataclasses import dataclass, field

from firebase_admin import exceptions as firebase_exceptions

from app.firebase import get_messaging

logger = logging.getLogger(__name__)

# FCM caps a multicast send at 500 tokens.
_MULTICAST_LIMIT = 500

_BRAND_COLOR = "#E31A1A"

# Errors that mean "this token is dead, stop storing it".
_DEAD_TOKEN_CODES = {"NOT_FOUND", "INVALID_ARGUMENT", "UNREGISTERED", "SENDER_ID_MISMATCH"}


@dataclass
class BroadcastStats:
    success_count: int = 0
    failure_count: int = 0
    invalid_tokens: set[str] = field(default_factory=set)

    @property
    def attempted(self) -> int:
        return self.success_count + self.failure_count


def build_notification_text(request: dict) -> tuple[str, str]:
    blood_group = request.get("bloodGroup") or "Blood"
    location = (request.get("location") or "").strip()
    requester = (request.get("fullName") or "Someone").strip()
    urgent = request.get("urgency") == "Urgent"

    title = f"🩸 URGENT: {blood_group} blood needed" if urgent else f"🩸 {blood_group} blood needed"
    if location:
        body = f"{requester} needs {blood_group} blood at {location}. Tap to help."
    else:
        body = f"{requester} needs {blood_group} blood. Tap to help."
    return title, body


def _data_payload(request_id: str, request: dict) -> dict[str, str]:
    """FCM data values must all be strings."""
    payload = {
        "type": "blood_request",
        "requestId": request_id,
        "fullName": request.get("fullName") or "",
        "bloodGroup": request.get("bloodGroup") or "",
        "location": request.get("location") or "",
        "phoneNumber": request.get("phoneNumber") or "",
        "urgency": request.get("urgency") or "Not Urgent",
        "note": request.get("note") or "",
        # Lets the app route the tap without another round trip.
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
    }
    units = request.get("unitsNeeded")
    if units:
        payload["unitsNeeded"] = str(units)
    return payload


def _is_dead_token(exception: Exception | None) -> bool:
    if exception is None:
        return False
    messaging = get_messaging()
    if isinstance(exception, (messaging.UnregisteredError, messaging.SenderIdMismatchError)):
        return True
    if isinstance(exception, firebase_exceptions.InvalidArgumentError):
        return True
    code = getattr(exception, "code", None)
    return isinstance(code, str) and code.upper() in _DEAD_TOKEN_CODES


def broadcast_blood_request(
    request_id: str,
    request: dict,
    tokens: list[str],
    *,
    dry_run: bool = False,
) -> BroadcastStats:
    """Push the request to every token, 500 at a time. Never raises for a
    partial failure - the caller reports how many people were actually reached."""
    stats = BroadcastStats()
    if not tokens:
        return stats

    messaging = get_messaging()
    title, body = build_notification_text(request)
    data = _data_payload(request_id, request)
    urgent = request.get("urgency") == "Urgent"

    android = messaging.AndroidConfig(
        priority="high",
        # Urgent requests are worthless once stale; give them a shorter life.
        ttl=3600 if urgent else 86400,
        notification=messaging.AndroidNotification(
            title=title,
            body=body,
            color=_BRAND_COLOR,
            sound="default",
            # Collapsing by request id keeps the tray tidy on re-broadcast.
            tag=f"blood_request_{request_id}",
        ),
    )
    apns = messaging.APNSConfig(
        headers={"apns-priority": "10" if urgent else "5"},
        payload=messaging.APNSPayload(
            aps=messaging.Aps(
                alert=messaging.ApsAlert(title=title, body=body),
                sound="default",
                badge=1,
            )
        ),
    )

    for start in range(0, len(tokens), _MULTICAST_LIMIT):
        chunk = tokens[start : start + _MULTICAST_LIMIT]
        message = messaging.MulticastMessage(
            tokens=chunk,
            notification=messaging.Notification(title=title, body=body),
            data=data,
            android=android,
            apns=apns,
        )

        try:
            batch_response = messaging.send_each_for_multicast(message, dry_run=dry_run)
        except firebase_exceptions.FirebaseError:
            logger.exception("FCM rejected a batch of %s tokens", len(chunk))
            stats.failure_count += len(chunk)
            continue

        stats.success_count += batch_response.success_count
        stats.failure_count += batch_response.failure_count

        for token, response in zip(chunk, batch_response.responses):
            if response.success:
                continue
            if _is_dead_token(response.exception):
                stats.invalid_tokens.add(token)
            else:
                logger.warning("Push to token %s… failed: %s", token[:12], response.exception)

    logger.info(
        "Broadcast %s: %s delivered, %s failed, %s stale token(s)",
        request_id,
        stats.success_count,
        stats.failure_count,
        len(stats.invalid_tokens),
    )
    return stats
