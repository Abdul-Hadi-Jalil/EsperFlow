"""Blood group helpers.

Every registered user is notified about a request, but it is useful to tell the
requester how many of those people can *actually* donate to them, so the UI can
say "24 users notified - 9 of them are compatible donors".
"""

from __future__ import annotations

BLOOD_GROUPS: tuple[str, ...] = ("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")

# recipient group -> donor groups whose red cells they can safely receive
COMPATIBLE_DONORS: dict[str, frozenset[str]] = {
    "A+": frozenset({"A+", "A-", "O+", "O-"}),
    "A-": frozenset({"A-", "O-"}),
    "B+": frozenset({"B+", "B-", "O+", "O-"}),
    "B-": frozenset({"B-", "O-"}),
    "AB+": frozenset(BLOOD_GROUPS),
    "AB-": frozenset({"AB-", "A-", "B-", "O-"}),
    "O+": frozenset({"O+", "O-"}),
    "O-": frozenset({"O-"}),
}


def normalize(group: str | None) -> str | None:
    """Tolerate 'a+', ' O- ', 'AB Positive' style input from the client."""
    if not group:
        return None
    cleaned = str(group).strip().upper().replace(" ", "")
    cleaned = cleaned.replace("POSITIVE", "+").replace("POS", "+")
    cleaned = cleaned.replace("NEGATIVE", "-").replace("NEG", "-")
    return cleaned if cleaned in COMPATIBLE_DONORS else None


def can_donate_to(donor_group: str | None, recipient_group: str | None) -> bool:
    donor = normalize(donor_group)
    recipient = normalize(recipient_group)
    if donor is None or recipient is None:
        return False
    return donor in COMPATIBLE_DONORS[recipient]
