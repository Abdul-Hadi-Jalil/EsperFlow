# EsperFlow — The Complete Project Book

*A full technical narrative of the EsperFlow blood-donation application: its vision, architecture, every screen and widget, its data model, platform configuration, current state, known gaps, and roadmap.*

---

**Document status:** Living document — reflects the repository as of the `main` branch, commit `85a8f53` ("added fcm token in blood donation screen").
**Audience:** Developers, reviewers, new contributors, and stakeholders who want to understand the whole system without reading every file.
**Scope:** The `frontend/` Flutter application and its Firebase backend. The `backend/` folder currently exists but is empty.

---

## Table of Contents

**Part I — Orientation**
1. Introduction & Vision
2. What EsperFlow Does Today (Honest Snapshot)
3. Repository Layout
4. Technology Stack

**Part II — Architecture**
5. Application Bootstrap & Entry Point
6. Navigation & Routing Model
7. State Management Philosophy
8. Firebase Backend & Data Model
9. The Notification (FCM) Pipeline

**Part III — Feature Walkthrough (Screen by Screen)**
10. Home Screen
11. Authentication — Login
12. Authentication — Register
13. Blood Request
14. Blood Donate
15. Profile
16. Donation History
17. Blood Banks & Organizations
18. Verified Hospitals
19. Emergency Contacts
20. FAQ
21. About Us
22. The `App` Auth Gate (currently dormant)

**Part IV — Building Blocks**
23. Reusable Widgets
24. Data Models

**Part V — Platform & Configuration**
25. Firebase Options & Multi-Platform Config
26. Android Configuration & Permissions
27. Assets, Theming & Branding

**Part VI — Engineering Practice**
28. How to Build & Run
29. Testing State
30. Project Evolution (Git History)

**Part VII — Assessment**
31. Known Issues, Bugs & Technical Debt
32. Security & Privacy Considerations
33. Roadmap & Recommendations

**Appendices**
- A. File Index
- B. Firestore Data Dictionary
- C. Route Table
- D. Dependency Reference
- E. Glossary

---

# Part I — Orientation

## 1. Introduction & Vision

**EsperFlow** is a mobile application whose mission — stated verbatim in its own *About Us* screen — is:

> "To create a centralized platform that bridges the gap between blood donors and those in need… to revolutionize the blood donation ecosystem by providing a reliable, efficient, and accessible system that connects willing donors with recipients during critical times."

The name blends *esper* (from *esperar* / *esperanza* — "hope") with *flow* (the flow of blood, and of help). The tagline that appears on the login screen is **"Donate Life, Save Lives,"** and the About screen uses **"Connecting Life, Saving Lives."**

The product is regionally focused on **Pakistan** — the seed data (hospitals, blood banks, emergency numbers) is all Pakistani, phone fields default to the `+92` country code, and the FAQ answers reference Pakistani donation norms. The founder/CEO listed in the app is **Abdul Hadi Jalil**, who is also the sole author of every commit in the repository.

The core idea is a **community-driven, two-sided marketplace for blood**:

- **Requesters** post that they need blood (a blood group, a location, an urgency level).
- **Donors** register their availability (blood group, location, contact preferences) and receive push notifications via Firebase Cloud Messaging (FCM).
- A set of **supporting reference tools** (verified hospitals, blood banks, emergency contacts, FAQ) help users who cannot find a match through the app itself.

EsperFlow is a Flutter app targeting **Android, iOS, Web, Windows, macOS, and Linux** from a single codebase, with **Firebase** (Auth, Cloud Firestore, Cloud Messaging) as its serverless backend.

## 2. What EsperFlow Does Today (Honest Snapshot)

It is important to separate the *aspiration* from the *current build*. This book documents both, but this chapter is the ground truth so nobody is misled.

**The app currently boots directly into the Home Screen with no login gate.** In `main.dart`, the `home:` is hard-wired to `HomeScreen()`, and only three routes are registered: Home, Blood Request, and Blood Donate. Every other screen — Login, Register, Profile, Blood Banks, Verified Hospitals, Donation History, Emergency Contacts, FAQ, About Us — is **fully implemented but commented out** of the route table and the Home menu. They exist as complete Dart files but are not reachable through the running app right now.

Feature-by-feature reality:

| Area | State |
|---|---|
| Home screen UI | ✅ Working; shows two active menu cards (Request / Donate) |
| Blood **Donate** flow | ✅ Writes a document to Firestore `donors/{uuid}` including an FCM token |
| Blood **Request** flow | ⚠️ UI complete, but **does not persist anything** — `saveBloodRequestData()` only flips a loading flag |
| Login (email/password) | ✅ Fully coded with validation & Firebase Auth — but unreachable (commented out) |
| Register | ⚠️ UI + validation scaffolding coded, but **no submit button and no Firebase write** — it collects data and does nothing with it |
| Profile | ✅ Rich implementation (load/edit/photo upload) — but unreachable |
| Donation History | ✅ Coded with a Firestore sub-collection — but unreachable |
| Blood Banks / Verified Hospitals / Emergency / FAQ / About | ✅ Complete static/reference screens — but unreachable |
| Auth gate (`App` widget) | ⚠️ Written but not used (`main.dart` imports it commented-out) |
| Push notifications | ⚠️ Token is captured and stored, but there is **no send-side, no background handler, and no `onMessage` listener** |
| Backend server | ❌ `backend/` folder is empty |
| Automated tests | ❌ Only the default Flutter counter smoke-test, which does not match this app and will fail |

In short: **EsperFlow is a mid-development prototype.** The visual and structural work is substantial and polished; the wiring that would make it a coherent end-to-end product is partially connected. The most recent development effort (per git history) has been narrowing focus to the Blood Request and Blood Donate screens, deliberately commenting the rest out.

## 3. Repository Layout

```
EsperFlow/
├── backend/                     # EMPTY — reserved for a future server component
├── docs/
│   └── EsperFlow-Project-Book.md   # ← this document
└── frontend/                    # The Flutter application (the whole product today)
    ├── pubspec.yaml             # Dependencies & asset declarations
    ├── pubspec.lock             # Resolved dependency versions
    ├── firebase.json            # FlutterFire platform mapping
    ├── analysis_options.yaml    # Lint rules (flutter_lints)
    ├── .metadata                # Flutter tool metadata
    ├── README.md                # Default Flutter template readme (not customized)
    ├── assets/
    │   └── images/
    │       ├── esperflow_logo.png
    │       ├── home_screen_footer.png
    │       └── h.png
    ├── lib/                     # ← ALL application source code
    │   ├── main.dart            # Entry point + MaterialApp + routes
    │   ├── app.dart             # Auth-gate wrapper (dormant)
    │   ├── firebase_options.dart# Generated FlutterFire config (all platforms)
    │   ├── models/
    │   │   └── donation_history.dart   # Stub model
    │   ├── screens/             # 12 screen files
    │   │   ├── home_screen.dart
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   ├── blood_request_screen.dart
    │   │   ├── blood_donate_screen.dart
    │   │   ├── profile_screen.dart
    │   │   ├── donation_history_screen.dart
    │   │   ├── blood_bank_screen.dart
    │   │   ├── verified_hospital_screen.dart
    │   │   ├── emergency_contact_screen.dart
    │   │   ├── faq_screen.dart
    │   │   └── about_us_screen.dart
    │   └── widgets/             # 3 reusable widgets
    │       ├── menu_item_card.dart
    │       ├── my_custom_buttom.dart   # (sic — misspelled "button")
    │       └── my_text_field.dart
    ├── test/
    │   └── widget_test.dart     # Default counter test (does not fit this app)
    ├── android/                 # Android runner + Gradle + google-services.json
    ├── ios/                     # iOS runner
    ├── web/                     # Web runner
    ├── windows/  macos/  linux/ # Desktop runners
```

**Key observations about the layout:**

- The project uses a **monorepo intent** (`frontend/` + `backend/`) but only the frontend exists. The empty `backend/` signals a planned server (likely to send FCM pushes and coordinate requests/donors), which has not been started.
- **All meaningful logic lives in `frontend/lib/`** — 18 Dart files totalling the app's behaviour.
- The `docs/` folder (containing this book) is the first documentation beyond the untouched default `README.md`.

> **Note on git status:** At the time of writing, `git status` shows a large number of files marked deleted at the *repository root* (`.gitignore`, `android/…`, `ios/…`, `lib/…`, etc.). This is because the project was reorganized — the Flutter app was moved from the repo root down into `frontend/`. Git is showing the old root-level paths as deleted while the new `frontend/`-prefixed copies are untracked/moved. This is a housekeeping artifact of the restructure, not lost work.

## 4. Technology Stack

**Language & Framework**
- **Dart** SDK `^3.10.0` (lock file resolves `>=3.10.0 <4.0.0`)
- **Flutter** stable channel, `>=3.35.0` (metadata revision `b45fa18946…`)
- **Material Design** (`uses-material-design: true`), Material 3 via `ColorScheme.fromSeed`

**Backend-as-a-Service — Firebase** (project id `esperflow-1b828`)
- `firebase_core: ^4.8.0` — initialization
- `firebase_auth: ^6.1.3` — email/password authentication & password reset
- `cloud_firestore: ^6.4.0` — the primary datastore (NoSQL document DB)
- `firebase_messaging: ^16.2.1` — push notifications (token capture only, so far)

**Direct application dependencies**
| Package | Version | Used for |
|---|---|---|
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `image_picker` | ^1.2.1 | Selecting a profile photo from the gallery |
| `image` | ^4.7.2 | Image processing utilities (declared; not obviously used in `lib/`) |
| `url_launcher` | ^6.3.2 | `tel:`, `mailto:`, `https:` links (calls, emails, websites, maps) |
| `uuid` | ^4.5.3 | Generating a unique document id for a donor record |

**Dev dependencies**
- `flutter_test` (SDK) and `flutter_lints: ^6.0.0` (recommended lint set)

**Platform targets configured:** Android, iOS, Web, Windows, macOS. (Linux is scaffolded by Flutter but explicitly *not* configured in `firebase_options.dart`, which throws an `UnsupportedError` for Linux.)

---

# Part II — Architecture

## 5. Application Bootstrap & Entry Point

The application's life begins in [`lib/main.dart`](../frontend/lib/main.dart).

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const EsperFlow());
}
```

Two things happen before the UI renders:

1. **`WidgetsFlutterBinding.ensureInitialized()`** — required because we do async work (`await`) before `runApp`.
2. **`Firebase.initializeApp(...)`** — boots Firebase using platform-specific options resolved from `DefaultFirebaseOptions.currentPlatform` (see Chapter 25). This is `await`ed so that Auth/Firestore/Messaging are ready when the first screen builds.

The root widget is **`EsperFlow`**, a `StatelessWidget` that returns a `MaterialApp`:

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
  home: HomeScreen(),
  routes: { '/homeScreen': …, '/bloodRequestScreen': …, '/bloodDonateScreen': … },
)
```

**Design decisions embodied here:**

- **Red is the brand seed color.** `ColorScheme.fromSeed(seedColor: Colors.red)` generates the entire Material 3 palette from red — appropriate for a blood-donation identity. Note, however, that most screens *hard-code* their own reds (`Color(0xFFE31A1A)`, `Colors.red.shade50/700/800`) rather than reading from the generated `Theme.of(context).colorScheme`. The theme and the screens are visually consistent but not systematically linked.
- **The debug banner is disabled** for a cleaner look.
- **`home:` is `HomeScreen()`** — meaning the app opens on Home, *bypassing authentication entirely* in the current build.

**The commented-out history is instructive.** The top of `main.dart` and the `routes` map both contain large blocks of commented imports/routes for the other ten screens plus the `App` auth-gate wrapper. This is the fingerprint of a deliberate scope-narrowing: the developer temporarily reduced the live app to the Home → Request/Donate happy path while iterating on those flows.

## 6. Navigation & Routing Model

EsperFlow uses **Flutter's classic named-route navigation** (the `Navigator 1.0` imperative API), not a declarative router package.

**Active routes** (registered in `main.dart`):

| Route name | Destination |
|---|---|
| `/` (implicit `home:`) | `HomeScreen` |
| `/homeScreen` | `HomeScreen` |
| `/bloodRequestScreen` | `BloodRequestScreen` |
| `/bloodDonateScreen` | `BloodDonateScreen` |

Navigation is triggered via `Navigator.pushNamed(context, '/route')`. For example, the Home menu cards call `Navigator.pushNamed(context, '/bloodRequestScreen')`.

**Dormant routes referenced in code but not registered.** Several screens push to routes that do not currently exist in the route table, e.g.:
- Home's avatar taps `'/profileScreen'`
- Home's notification bell has an empty handler
- Login pushes `'/registerScreen'`
- Profile's bottom nav pushes `'/homeScreen'` and sign-out pushes `'/'`

Because those target routes are commented out of `main.dart`, tapping them in a hypothetical fully-wired build would throw a "route not found" error unless the routes are re-enabled. This is the single biggest re-wiring task to make the app whole again (see Chapter 33).

**A note on `pushNamed` vs. the back stack.** The app uses `pushNamed` for forward navigation (which keeps stacking screens). Profile's sign-out correctly uses `pushNamedAndRemoveUntil(context, '/', (route) => false)` to clear the stack — the right call for a logout. Elsewhere, repeated `pushNamed` between Home and Profile via the bottom navigation bar would grow the stack rather than swap tabs; a real tabbed shell (e.g., `IndexedStack`) would be the more correct pattern.

## 7. State Management Philosophy

EsperFlow deliberately uses **no state-management library** — no Provider, Riverpod, Bloc, or GetX. (The git log entry `8ef7df9 "delete provider, it was not used"` confirms a Provider was tried and removed.)

Instead the app relies entirely on Flutter's built-in primitives:

- **`StatefulWidget` + `setState`** for local, ephemeral UI state (form values, loading flags, edit mode, search filters, selected radio/dropdown values).
- **`TextEditingController`** for text inputs, properly disposed in `dispose()` in most screens.
- **`StreamBuilder`** for reactive Firebase data — notably:
  - `App` widget: `StreamBuilder<User?>` on `FirebaseAuth.instance.authStateChanges()` (the intended auth gate).
  - `DonationHistoryScreen`: `StreamBuilder<DocumentSnapshot>` on a user document.
- **`FutureBuilder`-style `async` loads** in `initState` (e.g., Profile's `_loadUserData()`).

**Consequences of this choice:**
- **Simplicity.** For an app of this size, `setState` is perfectly adequate and keeps the mental model small.
- **No shared/global state.** There is no in-memory session object; every screen that needs user data re-queries Firebase (`FirebaseAuth.instance.currentUser`, then a Firestore read). This is fine at small scale but means data isn't cached across screens.
- **State is screen-local.** The consequence is that, e.g., the donor's registration and the requester's request live only in Firestore, not in any app-wide store.

## 8. Firebase Backend & Data Model

Firebase is the entire backend. Three services are in play.

### 8.1 Cloud Firestore collections

The code reads/writes **three distinct shapes**, and — importantly — they are **not internally consistent** in naming. This is a key piece of technical debt (see Chapter 31).

**Collection `donors/{uuid}`** — written by the Blood Donate screen:
```jsonc
{
  "fullName": "…",            // camelCase
  "location": "…",
  "phoneNumber": "…",
  "availability": "…",
  "bloodGroup": "A+",
  "allowCalls": true,          // bool
  "activeDonorStatus": true,   // bool
  "fcmToken": "…",             // for push targeting
  "registeredAt": <serverTimestamp>
}
```
The document id is a **client-generated UUID v4**, *not* the Firebase Auth UID. This means a donor record is anonymous/device-scoped and is not linked to an authenticated user account.

**Collection `User/{authUid}`** — read/written by Profile & Donation History:
```jsonc
{
  "Full Name": "…",           // Title Case with spaces (!)
  "Blood Group": "…",
  "Phone Number": "…",
  "Current Address": "…",
  "CNIC Number": "…",         // Pakistani national ID
  "Health Issue": <bool|string|null>,
  "Last Blood Donation": <string|null>,
  "profilePicture": "<base64 string>",
  "updatedAt": <serverTimestamp>
}
```
Here the document id **is** the Firebase Auth UID (`user.uid`). Field names are human-readable "Title Case With Spaces" — unusual and fragile as map keys. The Profile screen defensively reads both styles (`data['Full Name'] ?? data['name']`), showing the author was aware of the inconsistency.

**Sub-collection `User/{authUid}/donations/{autoId}`** — read/written by Donation History:
```jsonc
{
  "donationDate": <Timestamp>,
  "location": "…",
  "verified": true,
  "addedOn": <serverTimestamp>
}
```

### 8.2 The two identity models don't meet

There is a conceptual seam running through the data model:

- **Donors** are stored under an anonymous **UUID** with `camelCase` fields and an FCM token.
- **Users** (the authenticated profile) are stored under the **Auth UID** with `Title Case` fields.

Nothing currently joins a `donors/*` record to a `User/*` record. A logged-in user who registers as a donor produces two unrelated documents. Unifying these (donor = a facet of a user) is a foundational refactor the project will eventually need.

### 8.3 Firebase Authentication

Email/password auth is implemented in the Login screen:
- `signInWithEmailAndPassword(email, password)` with client-side validation first.
- `sendPasswordResetEmail(email)` behind a "Forgot Password?" dialog.
- Sign-out via `FirebaseAuth.instance.signOut()` in Profile.
- The `App` widget wraps `authStateChanges()` to route logged-in users to Home and everyone else to Login — but this gate is not currently mounted (see Chapter 22).

**There is no registration write.** The Register screen collects a name, email, password, phone, blood group and address, but never calls `createUserWithEmailAndPassword` nor writes to Firestore. Account creation is therefore not wired end-to-end today.

## 9. The Notification (FCM) Pipeline

Push notifications are the intended mechanism to alert donors when their blood is requested. The current implementation covers only the **first half** of the pipeline.

**What exists (in Blood Donate's submit handler):**
```dart
final messaging = FirebaseMessaging.instance;
NotificationSettings settings =
    await messaging.requestPermission(alert: true, badge: true, sound: true);
String? fcmToken;
if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  fcmToken = await messaging.getToken();
}
// …stored on the donors/{uuid} document as `fcmToken`.
```

So the app: (a) asks the OS for notification permission, (b) fetches the device's FCM registration token when granted, and (c) persists that token alongside the donor record so a future server could target it.

**What is missing:**
- **No background message handler** (`FirebaseMessaging.onBackgroundMessage(...)`).
- **No foreground listener** (`FirebaseMessaging.onMessage.listen(...)`).
- **No local-notification rendering** (no `flutter_local_notifications`), so even a delivered data message wouldn't surface a heads-up notification while the app is foregrounded.
- **No send-side.** Nothing sends a push. That requires a trusted server (Cloud Function or the empty `backend/`) holding admin credentials to call FCM. This is presumably *why* `backend/` exists as a placeholder.

The pipeline today is therefore "**collect tokens now, build the sender later.**"

---

# Part III — Feature Walkthrough (Screen by Screen)

Each chapter below documents one screen: what the user sees, how it is built, what data it touches, and any noteworthy details or defects.

## 10. Home Screen
**File:** [`lib/screens/home_screen.dart`](../frontend/lib/screens/home_screen.dart) · **Route:** `/` and `/homeScreen` · **Reachable:** ✅ Yes

The landing screen and the app's hub.

**Layout (top to bottom):**
- A header `Row` with: a circular **avatar** (taps toward `/profileScreen`), the centered **EsperFlow logo** (150×150), and a **notification bell** `IconButton` (empty handler).
- A **2-column `GridView.count`** of `MenuItemCard`s with `childAspectRatio: 2`, `shrinkWrap: true`, and `NeverScrollableScrollPhysics` (so the outer column scrolls, not the grid).
- A footer image (`home_screen_footer.png`) pinned to the bottom via `MainAxisAlignment.spaceBetween`.

**Active menu items:** "Request Blood" → `/bloodRequestScreen`, "Donate Blood" → `/bloodDonateScreen`.

**Commented-out menu items** (the full intended menu): Verified Hospitals, Blood Banks, Donation History, FAQs, Emergency Contact, About Us, Chat Assistant. The presence of a **"Chat Assistant"** card (route `/chatBotScreen`, no screen file) reveals a planned but never-started AI chatbot feature (git log also references "added chat screen" commits, later removed/commented).

**State:** Holds `int currentIndex = 0` for a bottom navigation bar that is entirely commented out. So `currentIndex` is currently dead state.

**Notable:** Because Profile isn't a registered route, tapping the avatar today would fail. Home is visually the "front door" of the finished app but only two of its doors currently open.

## 11. Authentication — Login
**File:** [`lib/screens/login_screen.dart`](../frontend/lib/screens/login_screen.dart) · **Route:** `/` intended via `App` · **Reachable:** ❌ Commented out

A polished, complete email/password login screen — arguably the most fully-realized auth code in the app.

**UI:** App bar titled "ESPERFLOW"; tagline "Donate Life, Save Lives"; email field (with `email_outlined` suffix); password field (obscured, eye toggle); an inline **"Forgot Password?"** text button; a red **Login** button; the logo; and a **"Don't have an account? Register"** row pushing `/registerScreen`.

**Validation (client-side, before hitting Firebase):**
- Email required, and matched against `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`.
- Password required and `>= 6` characters.
- Errors are shown inline under each field via nullable `_emailError` / `_passwordError`, cleared on change.

**Firebase Auth handling:** `signInWithEmailAndPassword`, wrapped in `try/catch` on `FirebaseAuthException`, mapping error codes (`user-not-found`, `wrong-password`, `invalid-credential`, `too-many-requests`, `user-disabled`) to friendly SnackBar messages, with a generic fallback.

**Forgot-password dialog:** A `StatefulBuilder` `AlertDialog` re-validates the email and calls `sendPasswordResetEmail`, then reports success/failure via SnackBar.

**Minor note:** The regex `{2,4}` on the TLD would reject modern long TLDs (e.g., `.info`, `.museum`), and uses `context` across `await` gaps without a `mounted` check (a common Flutter lint). Neither is fatal.

## 12. Authentication — Register
**File:** [`lib/screens/register_screen.dart`](../frontend/lib/screens/register_screen.dart) · **Route:** `/registerScreen` (unregistered) · **Reachable:** ❌ Commented out

A "Register as Donor" form — **UI-complete but functionally inert.**

**UI:** Logo, "Register as Donor" heading, and fields for Full Name, Email, Password (label "Cannot be less than 7 characters"), Phone Number (`+92`), a Blood Group dropdown, and Current Address. Each field has an associated `_…Error` string and an on-change clearer via `_clearErrorOnChange(field)`.

**The critical gap:** There is **no submit button** in the build tree and **no `createUserWithEmailAndPassword` / Firestore write**. The error-state scaffolding exists but nothing sets those errors, and nothing consumes the entered data. As written, Register is a form that cannot register anyone. Completing it is a prerequisite for the auth-gated version of the app to function.

**Inconsistency:** Password label says "Cannot be less than 7 characters" whereas Login enforces `>= 6`. The two screens disagree on the minimum password length.

## 13. Blood Request
**File:** [`lib/screens/blood_request_screen.dart`](../frontend/lib/screens/blood_request_screen.dart) · **Route:** `/bloodRequestScreen` · **Reachable:** ✅ Yes

Where a user asks for blood. One of the two live flows.

**UI:** An app bar "Request Blood"; a red **"Important"** info card ("Your request will be visible to all users…"); a Full Name field; an optional Phone Number field; a **Blood Group dropdown** (styled in a red container with a `bloodtype` icon per item); a Location field ("City/Area/Hospital"); an **Urgent / Not Urgent** radio pair (default `selectedUrgency = 'No'`); and a red **Submit Request** button.

**Behaviour & the gap:** On submit it shows a confirmation `AlertDialog` and calls `saveBloodRequestData()` — but that method's entire body is:
```dart
Future<void> saveBloodRequestData() async {
  setState(() { _isSubmitting = true; });
}
```
It flips a loading flag and **never writes to Firestore**. So blood requests are collected in the UI and discarded. This is the highest-impact functional gap in the "live" part of the app: the Donate side persists, but the Request side does not, so the two sides can't actually meet.

**Also note:** `_isSubmitting` is set to `true` but never reset to `false`, so the button label would stick on "Submitting…".

## 14. Blood Donate
**File:** [`lib/screens/blood_donate_screen.dart`](../frontend/lib/screens/blood_donate_screen.dart) · **Route:** `/bloodDonateScreen` · **Reachable:** ✅ Yes

Where a user registers as an available donor. **The most complete end-to-end flow in the app** — it's the only screen that both captures data *and* persists it with an FCM token.

**UI:** App bar "Donate Blood"; the same red "Important" info card; Full Name; optional Phone Number; Blood Group dropdown; optional Location; optional **Availability Time**; a **"Privacy and Visibility"** section with two `Switch`es — **"Allow calls"** (`allowCalls`, default true) and **"Active Donor Status"** ("Active Donors appear in search", `activeDonorStatus`, default true); and a red **Submit Donation** button.

**Submit handler (the important part):**
1. Reads and trims all four text fields.
2. Generates a **UUID v4** as the Firestore document id (`deviceId`). (Named `deviceId` but it's a fresh random UUID each submit, not a stable device identifier.)
3. Requests **FCM permission** and, if authorized, fetches `messaging.getToken()`.
4. Writes the full donor record to `donors/{uuid}` (see §8.1), including `fcmToken` and a `registeredAt` server timestamp.

**Gaps / notes:**
- The success TODO is unimplemented (`// todo: Show success alert dialog`) — the user gets no confirmation that submission worked.
- `_isSubmitting` exists and `saveBloodDonateData()` is defined but **never called** in the submit path, so the button label never changes.
- `_availabilityController` is **not disposed** in `dispose()` (a minor leak; the other three are disposed).
- Because the id is a random UUID, a donor who submits twice creates two records; there's no upsert/identity.

## 15. Profile
**File:** [`lib/screens/profile_screen.dart`](../frontend/lib/screens/profile_screen.dart) · **Route:** `/profileScreen` (unregistered) · **Reachable:** ❌ Commented out

The richest screen in the codebase — a full user profile with load, inline edit, and photo upload. It assumes an authenticated user (`FirebaseAuth.instance.currentUser`).

**Data loading (`_loadUserData`):** Reads `User/{uid}`, defensively coalescing both naming styles (`data['Full Name'] ?? data['name']`, etc.). Handles the polymorphic `Health Issue` field (bool / "true"/"yes" string / null) and formats `Last Blood Donation` for display, tolerating ISO-8601 or pre-formatted strings. Emits verbose `print` diagnostics throughout and surfaces load errors with a **Retry** button.

**Profile photo:** `_pickAndUploadImage` uses `image_picker` to pick from the gallery, base64-encodes the bytes, and stores the string in Firestore field `profilePicture`. It's rendered with `MemoryImage(base64Decode(...))`.
> **Design caution:** Storing images as base64 *inside Firestore documents* is an anti-pattern — Firestore documents have a **1 MiB limit**, and base64 inflates size ~33%. Photos belong in Firebase Storage with only the URL in Firestore. This will break for anything but small images.

**Editing:** Toggling `isEditing` swaps display text for `TextField`s (name, blood type, phone, address). `_updateUserProfile` writes back to `User/{uid}` (Title Case keys) with an `updatedAt` timestamp, then reloads. Email is shown but not editable.

**Extras:** An "Additional Information" card (phone, address, CNIC, health-issue status with warning/check iconography); a "Donation History" section (empty-state illustration or a list of `DonationHistoryTile`s built from the single `Last Blood Donation` value); a **"Debug: Check Firestore Data"** developer button that dumps the raw doc into a SnackBar; and a **Sign Out** button that signs out and `pushNamedAndRemoveUntil('/')`.

**Bottom nav:** A two-item `BottomNavigationBar` (Home / Profile) that pushes `/homeScreen` on tapping Home.

**Housekeeping:** Contains many `print` statements and a visible debug button that should be stripped before release.

## 16. Donation History
**File:** [`lib/screens/donation_history_screen.dart`](../frontend/lib/screens/donation_history_screen.dart) · **Route:** `/donationHistoryScreen` (unregistered) · **Reachable:** ❌ Commented out

A dedicated view of a user's donations, backed by the `User/{uid}/donations` sub-collection.

**Behaviour:** In `initState`, opens a `StreamBuilder<DocumentSnapshot>` on the user doc (for the summary card) and separately `get()`s the `donations` sub-collection ordered by `donationDate desc` into `_donationHistory`.

**UI:** A summary `Card` (name, blood group, last donation, **total donations** = list length); then either an empty-state or a `ListView` of donation cards showing date (`_formatDate` handles `Timestamp` or `String`), location, and a **verified/pending** status badge.

**Developer aid:** A `FloatingActionButton` `_addTestDonation()` writes a fake donation (`Test Hospital`, `verified: true`) — explicitly marked "for development."

**Note:** `_userStream` is `late` and only assigned when `currentUser != null`; if no user is logged in, the `StreamBuilder` would reference an uninitialized `late` field. Safe only under the assumption that this screen is always reached authenticated.

## 17. Blood Banks & Organizations
**File:** [`lib/screens/blood_bank_screen.dart`](../frontend/lib/screens/blood_bank_screen.dart) · **Route:** `/bloodBanksScreen` (unregistered) · **Reachable:** ❌ Commented out

A **static directory** of eight Pakistani blood-donation organizations — a reference/fallback tool ("If EsperFlow cannot help, contact these organizations directly").

**Data:** A hard-coded `List<Map>` of orgs (Pakistan Red Crescent, Fatmid Foundation, Shaukat Khanum, Edhi, Chhipa, JDC, Punjab Blood Transfusion, Saylani) each with name, description, phone, website, icon, and brand color. Plus a `quickTips` list (donate every 56 days, hydrate, eat iron-rich food, bring ID) — defined but **not rendered**.

**Interactions:** Per-org **Call** (`url_launcher` `tel:` with digit-cleaning), **Website** (`https:` via `externalApplication`), and a formatted phone display (`_formatPhoneNumber` renders numbers as `+92 … … …`).

**Bug:** `_showErrorSnackBar` only `print`s — its name promises a SnackBar it never shows (there's no `BuildContext`/`ScaffoldMessenger` in scope at those call sites, since it's a stateless helper). Errors are silently swallowed to the console.

## 18. Verified Hospitals
**File:** [`lib/screens/verified_hospital_screen.dart`](../frontend/lib/screens/verified_hospital_screen.dart) · **Route:** `/verifiedHospitalsScreen` (unregistered) · **Reachable:** ❌ Commented out

A **searchable directory of 21 Lahore hospitals** (sourced, per a code comment, from an Excel sheet).

**Data:** Each hospital has name, address, phone, city, province, a Google Maps search link, a **type** (Public / Private / Military), and a note. A colored **type badge** distinguishes them (green/blue/orange).

**Search:** A live `TextEditingController` listener filters `allHospitals` by name/address/type/note/city (case-insensitive) into `filteredHospitals`, with a clear button and a "no results" empty state. A footer shows "*N* hospitals found (*total* total)".

**Interactions:** Per-hospital **Call** (`tel:`) and **Directions** (opens the Maps link). This is the app's best example of a filtered list UI.

## 19. Emergency Contacts
**File:** [`lib/screens/emergency_contact_screen.dart`](../frontend/lib/screens/emergency_contact_screen.dart) · **Route:** `/emergencyContactScreen` (unregistered) · **Reachable:** ❌ Commented out

A quick-reference list of **eight Pakistani emergency numbers** (Rescue 1122, Edhi Ambulance 115, Police 15, hospital lines, Blood Donor Helpline 1134, etc.), with the three most urgent flagged `isCritical: true` (rendered with heavier borders/fills).

**Interaction model — copy, not call.** Unlike the other directories, tapping a card or its copy icon **copies the number to the clipboard** (`Clipboard.setData`) and shows a confirming SnackBar, rather than dialing. An extended FAB returns Home.

## 20. FAQ
**File:** [`lib/screens/faq_screen.dart`](../frontend/lib/screens/faq_screen.dart) · **Route:** `/faqScreen` (unregistered) · **Reachable:** ❌ Commented out

A simple, static Q&A screen: the logo, a "Frequently Asked Questions" heading, and seven `QATile` cards covering Pakistani donation basics (eligibility 18–60 & ≥50 kg, donation frequency, volume taken, safety, duration, medication, and whether EsperFlow charges — "No…"). `QATile` is a small local `StatelessWidget` formatting each Q (red) and A (green) pair. The last answer is truncated mid-sentence ("we only…"), an unfinished string.

## 21. About Us
**File:** [`lib/screens/about_us_screen.dart`](../frontend/lib/screens/about_us_screen.dart) · **Route:** `/aboutUsScreen` (unregistered) · **Reachable:** ❌ Commented out

The brand/mission page and the source of the project's stated vision.

**Content:** A gradient header banner (blood-drop icon, "EsperFlow", "Connecting Life, Saving Lives"); the full **Mission** statement; and a **"Meet Our Team"** section listing one owner — **Abdul Hadi Jalil, CEO** — with a description and tappable contact card (phone with call+copy, email with mailto+copy via `url_launcher`).

**Note:** The file opts out of a deprecation lint (`// ignore_for_file: deprecated_member_use`) because it uses `Color.withOpacity(...)`, which newer Flutter deprecates in favor of `.withValues(...)`. It contains **real personal contact details** (a phone number and email) hard-coded in source — worth treating as sensitive.

## 22. The `App` Auth Gate (currently dormant)
**File:** [`lib/app.dart`](../frontend/lib/app.dart) · **Reachable:** ❌ Not mounted

A tiny but architecturally important widget: the **intended front door** of the authenticated app.

```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) =>
      snapshot.hasData ? HomeScreen() : LoginScreen(),
)
```

It reactively shows `HomeScreen` to signed-in users and `LoginScreen` to everyone else. In the finished app, `main.dart`'s `home:` should be `App()` (or the `App` should be the `'/'` route). Today `main.dart` imports it only in a comment and sets `home: HomeScreen()` directly — so the gate never runs and the app is effectively unauthenticated. Re-enabling this one widget is the pivot from "prototype that opens on Home" to "product that opens on Login."

---

# Part IV — Building Blocks

## 23. Reusable Widgets

Three custom widgets live in `lib/widgets/`. They are simple, presentational, and shared across screens.

### `MyTextField` — [`lib/widgets/my_text_field.dart`](../frontend/lib/widgets/my_text_field.dart)
The app's standard text input. A `StatefulWidget` wrapping `TextField` with:
- A red-tinted fill (`Colors.red.shade50`), rounded, borderless look consistent with the brand.
- `maxLength: 120` (with the counter hidden).
- **Password support:** when `obsecureFlag` is true (note the misspelling of "obscure"), it manages its own `_isObscured` state and renders a visibility toggle (eye) suffix icon. Otherwise it can show an arbitrary `suffixIcon`.
- Optional `labelText`, `keyboardType`, `onChanged`, `validator`, `onSuffixTap`.
Used by Login, Register, Blood Request, Blood Donate.

### `MyCustomButtom` — [`lib/widgets/my_custom_buttom.dart`](../frontend/lib/widgets/my_custom_buttom.dart)
*(filename and class name both misspell "button")* A `GestureDetector`-wrapped rounded `Container` acting as a button, with `backgroundColor`, `text`, optional `textColor`, and an `onTap` callback. Used for the primary red action buttons (Login, Submit Request, Submit Donation).
> Because it's a `GestureDetector`, it provides no ink ripple, disabled state, or built-in loading spinner — an `ElevatedButton` would be more idiomatic and accessible.

### `MenuItemCard` — [`lib/widgets/menu_item_card.dart`](../frontend/lib/widgets/menu_item_card.dart)
The Home-screen grid tile: a bordered rounded `Container` with an icon and bold label, tappable via `onTap`. Used to build the Home menu.

**Cross-cutting observation:** The two misspellings (`my_custom_buttom`, `obsecureFlag`) are harmless but propagate through call sites; a rename would be a clean, low-risk polish.

## 24. Data Models

There is exactly one model file, and it is a stub:

### `DonationHistory` — [`lib/models/donation_history.dart`](../frontend/lib/models/donation_history.dart)
```dart
class DonationHistory {
  String? donation;
}
```
A single nullable field, no constructor, no `fromMap`/`toMap`, and **not referenced anywhere** in the app. The real "models" of the system are the untyped `Map<String, dynamic>` shapes read from and written to Firestore (Chapter 8). The absence of typed models is a notable gap: every Firestore field is accessed by string key with `??` fallbacks, which is where much of the naming-inconsistency risk lives. Introducing proper `Donor`, `AppUser`, `BloodRequest`, and `Donation` model classes (with `toMap`/`fromMap`) would eliminate a whole class of bugs.

---

# Part V — Platform & Configuration

## 25. Firebase Options & Multi-Platform Config
**File:** [`lib/firebase_options.dart`](../frontend/lib/firebase_options.dart) (FlutterFire-generated)

`DefaultFirebaseOptions.currentPlatform` switches on `defaultTargetPlatform` (and `kIsWeb`) to return per-platform `FirebaseOptions` for **Android, iOS, Web, Windows, macOS**. All point at Firebase project **`esperflow-1b828`** (messaging sender id `272472365314`). **Linux throws `UnsupportedError`** — so desktop Linux is not a supported target despite Flutter scaffolding a `linux/` runner.

`firebase.json` maps the Android app to `android/app/google-services.json` (which is present) and records the FlutterFire configuration.

> **On the committed API keys:** Firebase "API keys" in this file are *client identifiers*, not secrets — Google's model expects them in client apps, and they're constrained by Firebase Security Rules and (optionally) App Check. So committing `firebase_options.dart` and `google-services.json` is normal. **However**, this means the real security boundary is **Firestore Security Rules**, which are *not present in this repo*. See Chapter 32.

## 26. Android Configuration & Permissions
**Files:** [`android/app/src/main/AndroidManifest.xml`](../frontend/android/app/src/main/AndroidManifest.xml), [`android/app/build.gradle.kts`](../frontend/android/app/build.gradle.kts)

**Manifest highlights:**
- Package `com.example.esperflow`, app label "esperflow".
- **Permissions:** `INTERNET` (required for Firebase). `CALL_PHONE` is present but commented out — the app uses the *dialer* (`DIAL`) rather than placing calls directly, so no runtime call permission is needed.
- **`<queries>`** declare intents for `PROCESS_TEXT`, `VIEW` (http/https), and `DIAL`/`CALL` (tel) — necessary on Android 11+ so `url_launcher` can resolve browsers, the dialer, and Maps.
- `android:usesCleartextTraffic="true"` — allows plain HTTP (one blood-bank website in the directory is `http://`).
- Standard single-`MainActivity`, Flutter-embedding-v2 setup.

**Gradle:**
- Applies the **Google Services** plugin (`com.google.gms.google-services`) for Firebase.
- Java/Kotlin target **17**.
- `applicationId = "com.example.esperflow"` (still the default example id — a **TODO** to change before publishing).
- Release builds are **signed with the debug key** (a placeholder — must be replaced with a real keystore before store release).

## 27. Assets, Theming & Branding

**Declared assets (`pubspec.yaml`):** `esperflow_logo.png` and `home_screen_footer.png`. A third image, `h.png`, exists in `assets/images/` but is **not declared** in `pubspec.yaml` (so it can't be loaded at runtime) and isn't referenced in code — likely a leftover.

**Theming:** As noted, the global theme is a red-seeded Material 3 `ColorScheme`, but screens predominantly hard-code reds — the signature button color is `Color(0xFFE31A1A)`, and reference screens lean on `Colors.red.shade50/100/200/600/700/800`. The look is cohesive but the color system is duplicated rather than centralized. There is no custom font, no dark-theme definition, and no centralized design-token file.

---

# Part VI — Engineering Practice

## 28. How to Build & Run

The app is a standard FlutterFire project. From `frontend/`:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on a connected device / emulator (Android is the primary target)
flutter run

# 3. Build a release APK (note: currently debug-signed)
flutter build apk

# Other targets
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
```

**Prerequisites:** Flutter stable ≥ 3.35, Dart ≥ 3.10, an Android toolchain (SDK, JDK 17). Firebase is already configured via the committed `firebase_options.dart` and `google-services.json`, so no additional Firebase setup is needed to run against the `esperflow-1b828` project — provided that project's Firestore rules permit the operations (see Chapter 32).

**What you'll see:** The app opens on the **Home Screen** with two working cards — **Request Blood** (UI only, no save) and **Donate Blood** (saves a donor to Firestore and requests notification permission).

## 29. Testing State

Testing is effectively **non-existent**. The only test, [`test/widget_test.dart`](../frontend/test/widget_test.dart), is the **unmodified Flutter counter template**: it pumps `EsperFlow()` and asserts on a counter and a `+` FloatingActionButton that this app does not contain. **It will fail if run.** There are no unit tests for validation logic, no widget tests for the forms, and no integration tests for the Firebase flows. Establishing even a handful of real tests (email-regex validation, the donor-write map shape, empty-state rendering) would be high-value.

## 30. Project Evolution (Git History)

The repository has **50 commits**, all authored by **Abdul-Hadi-Jalil**. The arc of development, read oldest-to-newest, tells a clear story:

1. **UI-first foundation** — the earliest commits build screen UIs one at a time: login, register (with dropdown blood group), profile "husk", additional-information, blood request, home (moving to a `GridView.builder`), and the avatar.
2. **Wiring input & navigation** — bottom nav across Home/Profile; `TextEditingController`s added "in all screens for user input tracking"; a Provider is introduced to carry register data.
3. **Firebase integration** — "initialized firebase with this project", then "successfully implemented the login and register functionality with firebase and firestore for storing data."
4. **Content & reference screens** — About Us, Emergency Contacts, Verified Hospitals, Blood Banks, Donation History are added and iterated; validation is added to Login and Register.
5. **A chat-assistant experiment** — several "added chat screen" commits, later abandoned (the screen is gone; only a commented Home card and dead route remain).
6. **Consolidation & scope-narrowing (most recent)** — "delete provider, it was not used"; profile picture selection; a health note in blood request; and finally a deliberate pivot: *"fix some issues, comment all other screens except blood request and add new screen blood donate screen"*, followed by building the **Blood Donate** UI and **adding the FCM token** capture.

The trajectory: **broad UI prototyping → Firebase auth/data → many reference screens → refocus onto the core Request/Donate loop, now being wired for real with notifications.** The empty `backend/` and the token-capture work point at the next planned milestone: a server that sends pushes to matched donors.

---

# Part VII — Assessment

## 31. Known Issues, Bugs & Technical Debt

A consolidated, prioritized list drawn from the walkthroughs above.

**Blocking / functional**
1. **Blood Request doesn't persist.** `saveBloodRequestData()` only sets a flag; no Firestore write. The Request↔Donate loop is broken because requests vanish. *(blood_request_screen.dart)*
2. **Register doesn't register.** No submit button, no `createUserWithEmailAndPassword`, no Firestore write. *(register_screen.dart)*
3. **The app is unauthenticated.** `main.dart` opens on `HomeScreen` instead of the `App` auth gate; ten screens are commented out of routing and unreachable.
4. **Notification pipeline is half-built.** Tokens are captured but nothing sends or receives pushes; no background/foreground handlers. *(blood_donate_screen.dart, empty backend/)*

**Data-model / correctness**
5. **Inconsistent Firestore schemas.** `donors` uses `camelCase` under a random UUID; `User` uses "Title Case With Spaces" under the Auth UID. No link between a donor and a user. *(§8.2)*
6. **Profile photos stored as base64 in Firestore** — will hit the 1 MiB doc limit; belongs in Firebase Storage. *(profile_screen.dart)*
7. **No typed models.** Everything is stringly-typed `Map` access; the one model (`DonationHistory`) is an unused stub.

**Minor bugs / polish**
8. `_isSubmitting` never reset (Request); `saveBloodDonateData()` defined but never called (Donate) — the "Submitting…" states don't work.
9. `_availabilityController` not disposed (Donate) — small leak.
10. Donate success dialog is a `// todo` — no user confirmation on save.
11. `_showErrorSnackBar` in Blood Banks only `print`s — errors are invisible.
12. FAQ's last answer is truncated ("we only…").
13. Password min-length disagreement: Login `>= 6` vs. Register label "≥ 7".
14. `context`-across-`await` without `mounted` checks in several async handlers (Login, others).
15. Undeclared/unused asset `h.png`; misspellings `my_custom_buttom` / `obsecureFlag`.
16. Verbose `print` diagnostics and a visible "Debug: Check Firestore Data" button in Profile.
17. Default, incorrect `widget_test.dart` (will fail).
18. `applicationId` still `com.example.esperflow`; release build signed with the **debug** key.
19. `about_us_screen.dart` hard-codes a real personal phone/email and suppresses the `withOpacity` deprecation instead of migrating to `withValues`.

## 32. Security & Privacy Considerations

- **Firestore Security Rules are the real access boundary — and they aren't in this repo.** The committed Firebase API keys are fine (they're client identifiers), but the whole system's safety depends on server-side rules restricting who can read/write `donors`, `User`, and `donations`. If the project is running with permissive/test rules, **anyone could read every donor's name, phone, location, and FCM token, or write arbitrary data.** Locking down rules is the single most important security task. Consider also enabling **Firebase App Check**.
- **PII is central and sensitive.** The app collects names, phone numbers, locations, CNIC (national ID), blood group, and health flags. This is health-adjacent personal data and should be treated accordingly: minimal collection, access control, and a clear privacy policy. The in-app copy already tells users their info "will be visible to all users," which is a strong reason to gate visibility carefully.
- **Anonymous donor writes.** The Donate flow writes to `donors/*` with no authentication and a random id — trivially spammable without rules/App Check and rate limits.
- **Personal contact details in source** (About Us). Fine for a founder's public contact, but be intentional about it.
- **Cleartext HTTP enabled** on Android for one directory link — acceptable but worth minimizing.

## 33. Roadmap & Recommendations

A pragmatic path from "polished prototype" to "working product," roughly in order:

**Milestone 1 — Close the core loop**
- Implement the Firestore write in **Blood Request** (create a `bloodRequests` collection with group/location/urgency/contact + timestamp).
- Implement **Register**: add a submit button, `createUserWithEmailAndPassword`, and a `User/{uid}` write. Reconcile the password-length rules.
- Re-mount the **`App` auth gate** in `main.dart`; re-enable the commented routes and Home menu cards.

**Milestone 2 — Unify the data model**
- Introduce typed models (`AppUser`, `Donor`, `BloodRequest`, `Donation`) with `fromMap/toMap`.
- Standardize on one field-naming convention (recommend `camelCase` everywhere) and **link a donor profile to the authenticated user** (store donor data under the user, or key `donors` by `uid`).
- Move profile photos to **Firebase Storage** (URL in Firestore).

**Milestone 3 — Notifications for real**
- Build the send-side (Cloud Functions or the empty `backend/`): when a `bloodRequest` matches donors by blood group + location, send FCM to their stored tokens.
- Add background/foreground message handlers and local-notification rendering on the client.

**Milestone 4 — Hardening & release-readiness**
- Author and deploy **Firestore Security Rules** + App Check.
- Replace the debug signing config and set a real `applicationId`.
- Strip debug `print`s and the Profile debug button.
- Replace the placeholder test with a real test suite; fix the small bugs in Chapter 31.
- Fix truncated FAQ copy; clean up misspellings and the unused `h.png`/`DonationHistory` stub.
- Consider a matching/search UX so requesters can *find* donors (the "Active Donor appears in search" toggle implies a search that doesn't exist yet).

---

# Appendices

## Appendix A — File Index

| Path | Role | Reachable at runtime |
|---|---|---|
| `lib/main.dart` | Entry point, MaterialApp, routes | — |
| `lib/app.dart` | Auth-gate wrapper (StreamBuilder on auth state) | ❌ dormant |
| `lib/firebase_options.dart` | Per-platform Firebase config (generated) | — |
| `lib/models/donation_history.dart` | Stub model (unused) | ❌ |
| `lib/screens/home_screen.dart` | App hub / menu grid | ✅ |
| `lib/screens/login_screen.dart` | Email/password login + reset | ❌ commented |
| `lib/screens/register_screen.dart` | Registration form (no submit) | ❌ commented |
| `lib/screens/blood_request_screen.dart` | Request blood (no persist) | ✅ |
| `lib/screens/blood_donate_screen.dart` | Register as donor (+FCM, persists) | ✅ |
| `lib/screens/profile_screen.dart` | Profile: view/edit/photo | ❌ commented |
| `lib/screens/donation_history_screen.dart` | Donation sub-collection view | ❌ commented |
| `lib/screens/blood_bank_screen.dart` | Blood-bank directory (8 orgs) | ❌ commented |
| `lib/screens/verified_hospital_screen.dart` | Searchable hospital directory (21) | ❌ commented |
| `lib/screens/emergency_contact_screen.dart` | Emergency numbers (copy-to-clipboard) | ❌ commented |
| `lib/screens/faq_screen.dart` | 7-question FAQ | ❌ commented |
| `lib/screens/about_us_screen.dart` | Mission + team/contact | ❌ commented |
| `lib/widgets/menu_item_card.dart` | Home grid tile | ✅ (via Home) |
| `lib/widgets/my_custom_buttom.dart` | Primary button (sic) | ✅ |
| `lib/widgets/my_text_field.dart` | Standard text field | ✅ |
| `test/widget_test.dart` | Default counter test (mismatched) | ❌ will fail |

## Appendix B — Firestore Data Dictionary

**`donors/{uuidV4}`** — written by Blood Donate
| Field | Type | Notes |
|---|---|---|
| `fullName` | string | |
| `location` | string | optional |
| `phoneNumber` | string | optional |
| `availability` | string | free-text availability time |
| `bloodGroup` | string | one of A±, B±, AB±, O± |
| `allowCalls` | bool | |
| `activeDonorStatus` | bool | "appears in search" |
| `fcmToken` | string? | push target; null if permission denied |
| `registeredAt` | timestamp | server timestamp |

**`User/{authUid}`** — read/written by Profile, read by Donation History
| Field | Type | Notes |
|---|---|---|
| `Full Name` | string | Title-Case key |
| `Blood Group` | string | |
| `Phone Number` | string | |
| `Current Address` | string | |
| `CNIC Number` | string | national ID |
| `Health Issue` | bool \| string \| null | polymorphic; read defensively |
| `Last Blood Donation` | string \| null | ISO-8601 or pre-formatted |
| `profilePicture` | string | base64 image (anti-pattern) |
| `updatedAt` | timestamp | on edit |

**`User/{authUid}/donations/{autoId}`** — Donation History
| Field | Type | Notes |
|---|---|---|
| `donationDate` | Timestamp | ordered desc |
| `location` | string | |
| `verified` | bool | verified/pending badge |
| `addedOn` | timestamp | server timestamp |

*(Planned but not yet created: a `bloodRequests` collection to persist Blood Request submissions.)*

## Appendix C — Route Table

| Route | Screen | Registered? |
|---|---|---|
| `/` / `home:` | HomeScreen | ✅ |
| `/homeScreen` | HomeScreen | ✅ |
| `/bloodRequestScreen` | BloodRequestScreen | ✅ |
| `/bloodDonateScreen` | BloodDonateScreen | ✅ |
| `/loginScreen` | LoginScreen | ❌ commented |
| `/registerScreen` | RegisterScreen | ❌ commented (referenced by Login) |
| `/profileScreen` | ProfileScreen | ❌ commented (referenced by Home) |
| `/faqScreen` | FaqScreen | ❌ commented |
| `/emergencyContactScreen` | EmergencyContactScreen | ❌ commented |
| `/aboutUsScreen` | AboutUsScreen | ❌ commented |
| `/verifiedHospitalsScreen` | VerifiedHospitalsScreen | ❌ commented |
| `/bloodBanksScreen` | BloodBanksScreen | ❌ commented |
| `/donationHistoryScreen` | DonationHistoryScreen | ❌ commented |
| `/chatBotScreen` | *(no screen)* | ❌ planned, never built |

## Appendix D — Dependency Reference

*Runtime:* `firebase_core ^4.8.0`, `firebase_auth ^6.1.3`, `cloud_firestore ^6.4.0`, `firebase_messaging ^16.2.1`, `image_picker ^1.2.1`, `image ^4.7.2`, `url_launcher ^6.3.2`, `uuid ^4.5.3`, `cupertino_icons ^1.0.8`.
*Dev:* `flutter_test` (SDK), `flutter_lints ^6.0.0`.
*Environment:* Dart `^3.10.0`; Flutter stable `>=3.35.0`.

## Appendix E — Glossary

- **FCM (Firebase Cloud Messaging)** — Google's push-notification service. A device's *token* identifies where to deliver a message.
- **Firestore** — Firebase's NoSQL document database (collections → documents → fields, and sub-collections).
- **Auth UID** — the unique id Firebase assigns an authenticated user; used here as the `User/*` document id.
- **UUID v4** — a random 128-bit id (`uuid` package); used as the `donors/*` document id.
- **CNIC** — Computerized National Identity Card, Pakistan's national ID number.
- **Named route** — a string route (`/xyz`) registered on `MaterialApp` and navigated via `Navigator.pushNamed`.
- **`setState`** — Flutter's built-in mechanism to rebuild a `StatefulWidget` after local state changes.
- **Auth gate** — a widget that shows different screens based on whether a user is signed in; here, the dormant `App` widget.

---

*End of book. This document was generated by analyzing every source file in the repository. Where it describes gaps or bugs, those reflect the code as read on the `main` branch and are intended as an honest engineering assessment, not a criticism of an in-progress prototype.*
