# Chapter 2 — Architecture

[← Introduction](01-introduction.md) · [Table of Contents](README.md) · [Next: Getting Started →](03-getting-started.md)

---

## 2.1 The big picture

EsperFlow is a **thick client with one trusted server**. Most logic still lives inside the Flutter app, which calls the Firebase SDKs directly from `State` classes; Firebase provides authentication, storage, and push transport. One capability, however, **cannot** live on the client: delivering a push notification to other people's devices requires Firebase Admin credentials, and shipping those in an app would hand every user the keys to the project. That single responsibility is why the [FastAPI backend](../backend/README.md) exists.

> **The rule that shapes this architecture:** the client may *write* a blood request; only the server may *broadcast* it.

```mermaid
graph TB
    subgraph App["📱 EsperFlow Flutter App"]
        direction TB
        Main["main.dart<br/>bootstrap + routes"]
        Screens["screens/*<br/>12 feature screens"]
        Services["services/*<br/>NotificationService<br/>BloodRequestService"]
        Widgets["widgets/*<br/>reusable UI"]
        Models["models/*<br/>BloodRequest, BroadcastResult"]
        FBOpts["firebase_options.dart<br/>per-platform keys"]
        Main --> Screens
        Main --> Services
        Screens --> Services
        Screens --> Widgets
        Screens --> Models
        Main --> FBOpts
    end

    subgraph Server["🐍 FastAPI backend — the only trusted sender"]
        direction TB
        Routers["routers/*<br/>REST endpoints"]
        SvcLayer["services/*<br/>donors · fcm · blood_requests"]
        Admin["firebase-admin<br/>service-account key"]
        Routers --> SvcLayer --> Admin
    end

    subgraph Cloud["☁️ Firebase — project esperflow-1b828"]
        Auth["Authentication"]
        Firestore[("Cloud Firestore")]
        Msg["Cloud Messaging"]
    end

    subgraph OS["📲 Device capabilities"]
        Dialer["Phone dialer (tel:)"]
        Mail["Email client (mailto:)"]
        Browser["Web browser (https:)"]
        Maps["Google Maps"]
        Gallery["Photo gallery"]
        Clip["Clipboard"]
    end

    Screens -->|"signInWithEmailAndPassword<br/>sendPasswordResetEmail"| Auth
    Services -->|"bloodRequests.add(...)<br/>donors.set(...)"| Firestore
    Services -->|"requestPermission + getToken<br/>onMessage / onBackgroundMessage"| Msg
    Services -->|"POST /api/blood-requests"| Routers
    Admin -->|"read donors/*<br/>write notifiedCount"| Firestore
    Admin -->|"send_each_for_multicast"| Msg
    Msg -.->|"push to every donor device"| App
    Screens -->|url_launcher| Dialer
    Screens -->|url_launcher| Mail
    Screens -->|url_launcher| Browser
    Screens -->|url_launcher| Maps
    Screens -->|image_picker| Gallery
    Screens -->|Clipboard.setData| Clip

    style Server fill:#eef7ee,stroke:#2d7d2d
```

**Key consequences of this design:**

1. **The app is still mostly self-enforcing.** Every path except the broadcast talks to Firebase directly, so correctness depends on the client code and on **Firestore Security Rules** ([`backend/firestore.rules`](../backend/firestore.rules), deployed from the console — see [Chapter 16](16-security.md)).
2. **The broadcast is the one server-validated path.** Its payload is re-validated by Pydantic, and the delivery counters (`notifiedCount`, `notifiedAt`) are written by the server only — the rules deny them to clients, so a request cannot lie about how many people it reached.
3. **The app degrades, it does not break.** If the backend is unreachable the request is still saved to Firestore; only the notification is deferred, and the UI offers a retry.

---

## 2.2 Layers inside the app

The app has a shallow, conventional Flutter structure. There is **no state-management library** (no Provider/Bloc/Riverpod) — an earlier Provider was explicitly removed (git commit `8ef7df9` "delete provider, it was not used"). All state is local `setState` inside `StatefulWidget`s.

The blood request feature introduced a **`services/` layer**; the older screens still call Firebase inline. Both patterns are currently in the tree.

```mermaid
graph LR
    subgraph Presentation["Presentation layer"]
        S["Screens (StatefulWidget / StatelessWidget)"]
        W["Widgets (MyTextField, MyCustomButtom,<br/>RequestSentDialog, IncomingRequestDialog)"]
    end
    subgraph ServiceLayer["Service layer (new)"]
        BRS["BloodRequestService<br/>save → broadcast → result"]
        NS["NotificationService<br/>permission · token · handlers"]
        Cfg["ApiConfig<br/>dart-define'd base URL + key"]
    end
    subgraph Data["Data access"]
        FA["FirebaseAuth.instance"]
        FF["FirebaseFirestore.instance"]
        FM["FirebaseMessaging.instance"]
        HTTP["http → FastAPI backend"]
    end
    subgraph Model["Model"]
        M["BloodRequest · BroadcastResult<br/>DonationHistory (unused stub)"]
    end
    S --> W
    S --> BRS
    S -.->|"older screens, inline"| FA
    S -.->|"older screens, inline"| FF
    BRS --> FF
    BRS --> HTTP
    BRS --> NS
    NS --> FM
    BRS --> M
    BRS --> Cfg
```

| Layer | Where it lives | Notes |
|-------|----------------|-------|
| Presentation | [`lib/screens/`](../frontend/lib/screens/), [`lib/widgets/`](../frontend/lib/widgets/) | Screens own UI + orchestration; dialogs are extracted widgets |
| Services | [`lib/services/`](../frontend/lib/services/) | All I/O for the request feature: Firestore, HTTP, FCM |
| Config | [`lib/config/api_config.dart`](../frontend/lib/config/api_config.dart) | Backend URL and API key from `--dart-define`, never hard-coded |
| Data access | inline `FirebaseXxx.instance` calls | Still the pattern in Auth, Profile, Donate |
| Models | [`lib/models/`](../frontend/lib/models/) | `BloodRequest` / `BroadcastResult` are typed; older screens still pass untyped `Map`s |

> ⚠️ **Architectural debt (reduced, not gone):** the request feature now has a clean screen → service → I/O split, but Auth, Profile and Donate still interleave business logic, UI, and data access inside widget `State`. Migrating them to `services/` is the obvious next refactor. See [Chapter 15 §Recommendations](15-troubleshooting.md).

---

## 2.3 How a user request flows through the system

Most screens are still just a widget calling a Firebase SDK method. The exception — and the most complete flow in the system — is **submitting a blood request**, which crosses every tier:

```mermaid
sequenceDiagram
    actor User
    participant Req as BloodRequestScreen
    participant Svc as BloodRequestService
    participant FS as Cloud Firestore
    participant API as FastAPI backend
    participant FCM as Cloud Messaging
    actor Donors

    User->>Req: Fill form, tap "Submit Request"
    Req->>User: Confirm dialog
    Req->>Req: _validate()
    Req->>Svc: submit(request)
    Svc->>FS: bloodRequests.add({...,requesterFcmToken,createdAt})
    FS-->>Svc: documentRef.id
    Svc->>API: POST /api/blood-requests {requestId,...}
    API->>FS: read donors/* with an fcmToken
    API->>FCM: send_each_for_multicast(tokens)
    FCM-->>Donors: 🩸 push notification
    API->>FS: bloodRequests/{id}.update({notifiedCount,...})
    API-->>Svc: {notifiedCount, compatibleDonorCount,...}
    Svc-->>Req: BroadcastResult
    Req->>User: "Your request was sent to 24 registered users."
```

Note where the work happens: the app decides *what* to send, the server decides *who* receives it. Full detail in [Chapter 6](06-blood-request-and-donation.md) and [Chapter 11](11-notifications.md).

---

## 2.4 Navigation architecture

Navigation uses Flutter's built-in **named-route table** declared in [`main.dart`](../frontend/lib/main.dart). The entry widget is `HomeScreen` (via `home:`), and only three named routes are registered.

```mermaid
graph TD
    Root["MaterialApp<br/>home: HomeScreen"]
    Home["/homeScreen → HomeScreen ✅"]
    Req["/bloodRequestScreen → BloodRequestScreen ✅"]
    Don["/bloodDonateScreen → BloodDonateScreen ✅"]
    Root --> Home
    Home -->|"Request Blood tile"| Req
    Home -->|"Donate Blood tile"| Don
    Home -.->|"avatar tap → /profileScreen"| Missing["❌ route not registered<br/>(throws at runtime)"]

    style Missing fill:#ffdddd,stroke:#cc0000
```

The full route table, including every commented-out route, is in [Chapter 4 §Route table](04-app-entry-and-navigation.md#43-the-route-table) and the [Appendix](18-appendix.md#c-route-table).

---

## 2.5 Where the boundaries are

| Boundary | Crossed by | Protocol |
|----------|-----------|----------|
| App ↔ Firebase Auth | `firebase_auth` SDK | HTTPS to Google Identity Toolkit |
| App ↔ Firestore | `cloud_firestore` SDK | gRPC/HTTPS, real-time streams + one-shot reads |
| App ↔ FCM | `firebase_messaging` SDK | Token retrieval + push receipt (`onMessage`, `onBackgroundMessage`) |
| **App ↔ EsperFlow backend** | `http` package + [`ApiConfig`](../frontend/lib/config/api_config.dart) | **JSON over HTTP(S), `x-api-key` header** |
| **Backend ↔ Firestore / FCM** | `firebase-admin` (Python) | Service-account credentials, server-side only |
| App ↔ Phone/Email/Web/Maps | `url_launcher` | OS intent (`tel:`, `mailto:`, `https:`) |
| App ↔ Photo gallery | `image_picker` | OS picker intent |

The app-to-server boundary is **narrow by design**: exactly one endpoint is on the critical path (`POST /api/blood-requests`), and the app keeps working without it — a failed call leaves the request stored in Firestore with a retry available. Nothing else routes through the server, so it can be down without taking the app down.

The base URL and API key are injected at build time (`--dart-define=API_BASE_URL=…`), never hard-coded — see [Chapter 12](12-configuration-reference.md).

---

## 2.6 Deployment topology

```mermaid
graph LR
    Dev["Developer machine<br/>Flutter SDK"] -->|"flutter build<br/>--dart-define=API_BASE_URL"| APK["Android APK/AAB"]
    APK --> Device["User's Android device"]
    Device <-->|HTTPS/gRPC| FB["Firebase esperflow-1b828"]
    Device -->|"HTTPS + x-api-key"| Host["ASGI host<br/>(uvicorn: Cloud Run,<br/>Render, Railway, VM)"]
    Host <-->|"firebase-admin<br/>service-account key"| FB
    Console["Firebase Console<br/>(rules, users, data)"] --> FB

    style Host fill:#eef7ee,stroke:#2d7d2d
```

Two deployable artefacts now: the Flutter binary and the FastAPI service. The binary must be built with the backend's public URL baked in via `--dart-define`, so **deploy the backend first, then build the app**. There is still no CI/CD configured in the repo. See [Chapter 14 — Deployment](14-deployment.md).

---

[← Introduction](01-introduction.md) · [Table of Contents](README.md) · [Next: Getting Started →](03-getting-started.md)
