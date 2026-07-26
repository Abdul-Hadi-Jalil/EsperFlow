# Chapter 17 — Glossary

[← Security](16-security.md) · [Table of Contents](README.md) · [Next: Appendix →](18-appendix.md)

---

Terms used throughout this book, grouped by domain. Project-specific terms are marked **(EsperFlow)**.

## Project & domain

| Term | Meaning |
|------|---------|
| **EsperFlow** *(EsperFlow)* | The app documented here — a Flutter blood-donation app. Name = *esper* (hope) + *flow*. |
| **Donor** *(EsperFlow)* | A person offering to give blood; registered via the [Donate screen](06-blood-request-and-donation.md#62-blood-donate-screen) into the `donors` collection. |
| **Requester** *(EsperFlow)* | A person seeking blood; uses the [Request screen](06-blood-request-and-donation.md#61-blood-request-screen) (persistence not yet implemented). |
| **Blood group** | One of `A+ A- B+ B- AB+ AB- O+ O-`; used across Request/Donate/Register. |
| **CNIC** | *Computerized National Identity Card* — Pakistan's national ID number; a `User` field. |
| **Active Donor Status** *(EsperFlow)* | A donor switch meaning "appear in donor search" (`activeDonorStatus`). |
| **Allow calls** *(EsperFlow)* | A donor switch meaning "users may call me" (`allowCalls`). |
| **Auth gate** *(EsperFlow)* | The [`App`](04-app-entry-and-navigation.md#45-the-dormant-auth-gate-appdart) widget that would route by auth state; currently dormant. |
| **Two identity models** *(EsperFlow)* | The disconnect between `donors/{uuid}` (anonymous) and `User/{uid}` (authenticated) — see [Chapter 10](10-data-and-storage.md#104-the-two-identity-model-problem). |
| **Honest snapshot** *(EsperFlow)* | This book's convention of stating what actually works vs. what's stubbed — see [Chapter 1](01-introduction.md#22-honest-snapshot-what-actually-works-today). |

## Flutter / Dart

| Term | Meaning |
|------|---------|
| **Flutter** | Google's cross-platform UI framework; compiles Dart to native apps. |
| **Dart** | The programming language Flutter uses. |
| **Widget** | The basic UI building block; everything on screen is a widget. |
| **StatelessWidget** | A widget with no mutable state (e.g. `MenuItemCard`). |
| **StatefulWidget / State** | A widget with mutable state held in a companion `State` object (e.g. `HomeScreen`/`_HomeScreenState`). |
| **`setState`** | Marks state dirty so Flutter rebuilds the widget; EsperFlow's only state-management mechanism. |
| **`MaterialApp`** | Root widget configuring theme, routes, and home ([Chapter 4](04-app-entry-and-navigation.md)). |
| **Material 3** | The design system version used (red-seeded `ColorScheme.fromSeed`). |
| **Named route** | A string key (e.g. `/bloodDonateScreen`) mapped to a screen in `routes:`. |
| **`Navigator.pushNamed`** | Pushes a named route onto the navigation stack. |
| **`Scaffold`** | Page skeleton (app bar, body, FAB, bottom nav). |
| **`TextEditingController`** | Reads/controls a text field's contents. |
| **`StreamBuilder` / `FutureBuilder`** | Widgets that rebuild from async streams/futures (used for Firestore + auth state). |
| **`FloatingActionButton` (FAB)** | The circular action button (e.g. Donation History's "Add Test Donation"). |
| **pubspec** | [`pubspec.yaml`](../frontend/pubspec.yaml), the project manifest (deps, assets, version). |
| **pub / `flutter pub get`** | Dart's package manager / dependency fetch. |
| **`analysis_options.yaml`** | Configures the Dart analyzer/lints. |

## Firebase

| Term | Meaning |
|------|---------|
| **Firebase** | Google's backend-as-a-service platform used for auth, DB, and messaging. |
| **Firebase Authentication** | Managed user auth; EsperFlow uses email/password. |
| **Cloud Firestore** | NoSQL document database ([Chapter 10](10-data-and-storage.md)). |
| **Collection / Document** | Firestore's containers: a collection holds documents; a document holds fields (and can hold subcollections). |
| **Subcollection** | A collection nested under a document (e.g. `User/{uid}/donations`). |
| **`FieldValue.serverTimestamp()`** | A placeholder Firestore replaces with the server's write time. |
| **`Timestamp`** | Firestore's date/time type. |
| **`DocumentSnapshot` / `QuerySnapshot`** | Results of reading a document / a query. |
| **UID** | The unique ID Firebase Auth assigns each user; the key for `User` documents. |
| **FCM** | *Firebase Cloud Messaging* — push notifications ([Chapter 11](11-notifications.md)). |
| **FCM token** | A per-device push address; captured on donate, stored on the donor doc. |
| **`google-services.json`** | Android Firebase config file (client, not a secret). |
| **FlutterFire** | The official Firebase plugins + CLI for Flutter; generates `firebase_options.dart`. |
| **Security Rules** | Server-side Firestore access rules — the app's main access control ([Chapter 16](16-security.md)). |
| **Firebase Storage** | Firebase's file/blob store; recommended for profile images instead of base64-in-Firestore. |

## Packages used

| Package | Role |
|---------|------|
| **`url_launcher`** | Opens `tel:`, `mailto:`, `https:`, and maps URIs via the OS. |
| **`image_picker`** | Picks an image from the gallery/camera. |
| **`uuid`** | Generates random UUIDs (donor doc IDs). |
| **`image`** | Image processing utilities (declared; not central to current flows). |
| **`cupertino_icons`** | iOS-style icon font. |
| **`flutter_lints`** | Recommended lint rules (dev dependency). |

## General

| Term | Meaning |
|------|---------|
| **base64** | A text encoding of binary data; used to embed the profile image in Firestore (see the size caveat in [Chapter 7](07-profile-and-donation-history.md#71-profile-screen)). |
| **PII** | Personally Identifiable Information (names, phones, addresses, CNIC) — see [Chapter 16](16-security.md). |
| **Cleartext traffic** | Unencrypted HTTP; globally allowed on Android here via `usesCleartextTraffic`. |
| **APK / AAB** | Android app package / Android App Bundle build artifacts. |
| **APNs** | Apple Push Notification service (needed for iOS push; not configured). |

---

[← Security](16-security.md) · [Table of Contents](README.md) · [Next: Appendix →](18-appendix.md)
