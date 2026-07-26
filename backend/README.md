# EsperFlow Backend

FastAPI service that acts as EsperFlow's **trusted Cloud Messaging sender**. The
Flutter app can store a blood request in Firestore, but it must never hold the
Firebase Admin credentials needed to *deliver* a push — that is this service's job.

```
Request Blood screen
   │  1. write  bloodRequests/{id}          ──▶ Cloud Firestore
   │  2. POST /api/blood-requests {requestId, …}
   ▼
FastAPI backend
   │  3. read every donors/* document that has an fcmToken
   │  4. messaging.send_each_for_multicast(...)   ──▶ FCM ──▶ all devices
   │  5. write notifiedCount / notifiedAt back onto the request
   ▼
   6. respond { notifiedCount, totalRegisteredUsers, compatibleDonorCount }
      └─▶ the app shows "Your request was sent to 24 registered users."
```

---

## 1. Setup

```powershell
cd backend
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
```

(bash: `python3 -m venv .venv && source .venv/bin/activate`)

### Firebase Admin credentials

1. Firebase console → **Project settings → Service accounts → Generate new private key**.
2. Save the JSON as `backend/serviceAccountKey.json` (already git-ignored), **or**
   paste its contents into `FIREBASE_SERVICE_ACCOUNT_JSON` in `.env` (raw or base64 —
   handy for Render/Railway/Cloud Run where you cannot ship a file).

The key belongs to project `esperflow-1b828` — the same project as
`frontend/lib/firebase_options.dart`. A key from a different project will
authenticate fine and then silently fail to deliver to the app's tokens.

### Run

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
# or: python run.py
```

- Interactive API docs: <http://localhost:8000/docs>
- `GET /health` — liveness, never touches Firebase
- `GET /ready` — confirms the Admin credentials actually load

> **Android emulator:** the host machine is `10.0.2.2`, not `localhost`. A physical
> phone needs your LAN IP (`ipconfig`) and `--host 0.0.0.0`. See
> [frontend/lib/config/api_config.dart](../frontend/lib/config/api_config.dart).

---

## 2. API

| Method | Path | Purpose |
|---|---|---|
| `POST` | `/api/blood-requests` | Save (if needed) **and broadcast** a request to every registered user |
| `GET`  | `/api/blood-requests` | Recent requests, newest first (`?status=open&bloodGroup=A%2B&limit=50`) |
| `GET`  | `/api/blood-requests/{id}` | One request, including how many users it reached |
| `POST` | `/api/blood-requests/{id}/notify` | Re-send an existing request |
| `POST` | `/api/blood-requests/{id}/close` | Mark `fulfilled` / `cancelled` / `expired` |
| `GET`  | `/api/donors/reach` | Preview reach before submitting (`?bloodGroup=A%2B`) |

### `POST /api/blood-requests`

```jsonc
// request
{
  "requestId": "0KJ2…",          // optional: id of the doc the app already wrote
  "fullName": "Ayesha Khan",
  "bloodGroup": "A+",
  "location": "Lahore General Hospital",
  "phoneNumber": "03001234567",  // optional
  "urgency": "Urgent",           // or "Not Urgent"
  "unitsNeeded": 2,              // optional
  "note": "Ward 4, ask for Dr. Ali", // optional
  "requesterFcmToken": "fXYZ…"   // optional: excluded from the broadcast
}
```

```jsonc
// 201 response — this is what the confirmation dialog renders
{
  "success": true,
  "requestId": "0KJ2…",
  "notifiedCount": 24,           // devices FCM accepted the push for
  "totalRegisteredUsers": 25,    // registered users holding a push token
  "compatibleDonorCount": 9,     // of those, how many can donate to A+
  "failedCount": 1,
  "alreadyNotified": false,
  "message": "Your request was sent to 24 registered users. 9 of them have a compatible blood group."
}
```

Behaviour worth knowing:

- **Idempotent.** If the request id was already broadcast, the stored counts are
  returned with `alreadyNotified: true` instead of pushing twice. Use
  `/notify` to force a re-send.
- **De-duplicated.** The Donate screen writes a new `donors/{uuid}` document on
  every submit, so one device can appear many times; tokens are collapsed and the
  newest registration wins for blood group. `notifiedCount` counts *devices*, not documents.
- **Self-exclusion.** `requesterFcmToken` is dropped from the audience so you do
  not get pushed your own request.
- **Self-healing.** Tokens FCM reports as dead (app uninstalled, token rotated)
  are removed from their donor documents so the next broadcast is not slowed by them.
- **Partial failure is not an error.** If 3 of 25 pushes fail, you still get a 201
  with `notifiedCount: 22` and `failedCount: 3`.
- Everyone registered is notified; `compatibleDonorCount` is informational only.
  Set `NOTIFY_ONLY_ACTIVE_DONORS=true` to skip donors who turned off
  "Active Donor Status".

---

## 3. Configuration

All settings live in `.env` (see [`.env.example`](.env.example)).

| Variable | Default | Notes |
|---|---|---|
| `HOST` / `PORT` | `0.0.0.0` / `8000` | |
| `CORS_ORIGINS` | `*` | Comma separated, or `*` |
| `API_KEY` | *(empty)* | When set, every `/api` write requires header `x-api-key`. **Set this in production** — anyone who can reach the endpoint can push to every user |
| `FIREBASE_SERVICE_ACCOUNT_PATH` | `./serviceAccountKey.json` | |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | *(empty)* | Raw JSON or base64; wins over the path |
| `FIREBASE_PROJECT_ID` | `esperflow-1b828` | |
| `DONORS_COLLECTION` | `donors` | Must match the app |
| `BLOOD_REQUESTS_COLLECTION` | `bloodRequests` | Must match the app |
| `NOTIFY_ONLY_ACTIVE_DONORS` | `false` | `true` respects the donor's "Active Donor Status" switch |

Pass the same key to the app at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=API_KEY=your-secret
```

---

## 4. Firestore data

`donors/{uuid}` — written by the app's Donate Blood screen (unchanged by this service
except for stale-token cleanup):

| Field | Type | Used for |
|---|---|---|
| `fcmToken` | string | **the push address — no token, no notification** |
| `bloodGroup` | string | `compatibleDonorCount` |
| `activeDonorStatus` | bool | honoured when `NOTIFY_ONLY_ACTIVE_DONORS=true` |
| `registeredAt` | timestamp | newest registration wins per device |

`bloodRequests/{id}` — client writes the first block, the backend writes the second:

| Field | Written by |
|---|---|
| `fullName`, `phoneNumber`, `bloodGroup`, `location`, `urgency`, `isUrgent`, `unitsNeeded`, `note`, `requesterFcmToken`, `status`, `createdAt` | app |
| `notifiedCount`, `failedCount`, `totalRegisteredUsers`, `totalDonorProfiles`, `compatibleDonorCount`, `notificationStatus`, `notifiedAt` | backend |

Suggested security rules are in [`firestore.rules`](firestore.rules) — they let the
app create requests but keep the delivery counters server-only. Deploy with
`firebase deploy --only firestore:rules`.

---

## 5. Deployment notes

Any host that runs a Python ASGI app works:

```bash
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

Checklist: set `API_KEY`, supply `FIREBASE_SERVICE_ACCOUNT_JSON`, restrict
`CORS_ORIGINS`, serve over HTTPS (then drop `android:usesCleartextTraffic` from
the Android manifest), and point the app at the public URL with
`--dart-define=API_BASE_URL=https://…`.

Firestore reads scale linearly with the donor count: one broadcast reads every
donor document. Past a few thousand donors, switch to FCM **topics**
(`messaging.subscribe_to_topic`) so a single send fans out server-side.
