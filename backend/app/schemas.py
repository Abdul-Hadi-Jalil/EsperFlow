"""Request/response models. The wire format is camelCase to match the Flutter app."""

from __future__ import annotations

import re
from datetime import datetime
from typing import Annotated, Any, Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator
from pydantic.alias_generators import to_camel

from app.blood_groups import BLOOD_GROUPS, normalize

Urgency = Literal["Urgent", "Not Urgent"]

_PHONE_RE = re.compile(r"^[0-9+\-()\s]{7,20}$")


class CamelModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        str_strip_whitespace=True,
    )


class BloodRequestCreate(CamelModel):
    """Body of POST /api/blood-requests.

    `request_id` is set when the app already wrote the document to Firestore and
    just wants the server to broadcast it; when it is absent the server creates
    the document itself.
    """

    request_id: str | None = Field(default=None, max_length=200)
    full_name: Annotated[str, Field(min_length=2, max_length=120)]
    blood_group: str
    location: Annotated[str, Field(min_length=2, max_length=200)]
    phone_number: str | None = Field(default=None, max_length=20)
    urgency: Urgency = "Not Urgent"
    units_needed: int | None = Field(default=None, ge=1, le=20)
    note: str | None = Field(default=None, max_length=500)
    requester_fcm_token: str | None = Field(default=None, max_length=4096)

    @field_validator("blood_group")
    @classmethod
    def _check_blood_group(cls, value: str) -> str:
        group = normalize(value)
        if group is None:
            raise ValueError(f"blood group must be one of {', '.join(BLOOD_GROUPS)}")
        return group

    @field_validator("urgency", mode="before")
    @classmethod
    def _coerce_urgency(cls, value: Any) -> Any:
        if value is None:
            return "Not Urgent"
        if isinstance(value, bool):
            return "Urgent" if value else "Not Urgent"
        text = str(value).strip().lower()
        if text in {"urgent", "true", "yes", "high"}:
            return "Urgent"
        if text in {"not urgent", "noturgent", "no", "false", "normal", "low"}:
            return "Not Urgent"
        return value

    @field_validator("phone_number", "note", "requester_fcm_token", mode="before")
    @classmethod
    def _blank_to_none(cls, value: Any) -> Any:
        if isinstance(value, str) and not value.strip():
            return None
        return value

    @field_validator("phone_number")
    @classmethod
    def _check_phone(cls, value: str | None) -> str | None:
        if value and not _PHONE_RE.match(value):
            raise ValueError("phone number may only contain digits, spaces, + - ( )")
        return value


class BloodRequestOut(CamelModel):
    id: str
    full_name: str
    blood_group: str
    location: str
    phone_number: str | None = None
    urgency: Urgency = "Not Urgent"
    units_needed: int | None = None
    note: str | None = None
    status: str = "open"
    notified_count: int = 0
    compatible_donor_count: int = 0
    created_at: datetime | None = None
    notified_at: datetime | None = None


class BroadcastResult(CamelModel):
    """What the requester is shown after tapping Submit."""

    success: bool = True
    request_id: str
    # Devices FCM accepted the push for - "your request reached N people".
    notified_count: int = 0
    # Every registered user holding a push token (excluding the requester).
    total_registered_users: int = 0
    # Registered donors whose blood group is compatible with the request.
    compatible_donor_count: int = 0
    # Pushes FCM rejected (uninstalled app, stale token, ...).
    failed_count: int = 0
    already_notified: bool = False
    message: str = ""


class DonorReachOut(CamelModel):
    """Preview of how far a request would travel, used before submitting."""

    total_registered_users: int = 0
    reachable_devices: int = 0
    compatible_donor_count: int = 0
    blood_group: str | None = None


class ErrorOut(BaseModel):
    detail: str
