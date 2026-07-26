# EsperFlow — The Complete Project Book

> A chapter-by-chapter technical book that documents the entire EsperFlow codebase, written so that a developer or user who has never seen this project can learn it, understand it, and build on it from scratch.

EsperFlow is a **Flutter mobile application for community blood donation**, backed by **Firebase** (Authentication, Cloud Firestore, and Cloud Messaging). It lets people request blood, register as donors, browse verified hospitals and blood banks, find emergency contacts, and manage a personal donor profile.

This book is written **against the code as it actually exists today**, not against an idealised design. Where a screen is wired up but does nothing yet, or where two parts of the app disagree about how data is stored, the book says so plainly. Those honest notes are called out with a ⚠️ marker throughout.

---

## How to use this book

- **Brand-new to the project?** Read Chapters 1 → 4 in order. That gives you the "what, why, and how it boots" before you touch code.
- **Setting up a dev environment?** Jump to [Chapter 3 — Getting Started](03-getting-started.md).
- **Looking for one specific screen or file?** Use the deep-dive chapters (5–9) or the [file index in the Appendix](18-appendix.md).
- **Trying to understand the database?** Read [Chapter 10 — Data & Storage](10-data-and-storage.md).
- **Confused by something not working?** Check [Chapter 15 — Troubleshooting](15-troubleshooting.md), then [Chapter 1 §"Honest snapshot"](01-introduction.md#22-honest-snapshot-what-actually-works-today).

Every code reference links to the real file (for example [`lib/main.dart`](../frontend/lib/main.dart)). Diagrams use [Mermaid](https://mermaid.js.org/) and render directly on GitHub and in most Markdown viewers.

---

## Table of Contents

### Part I — Orientation
| # | Chapter | What it covers |
|---|---------|----------------|
| 1 | [Introduction & Project Overview](01-introduction.md) | What EsperFlow is, who it's for, the feature set, the tech stack, and an honest snapshot of what works today |
| 2 | [Architecture](02-architecture.md) | High-level system design, component diagram, and how the pieces communicate |
| 3 | [Getting Started](03-getting-started.md) | Prerequisites, installation, Firebase setup, and your first build/run |

### Part II — Deep Dives (module by module)
| # | Chapter | What it covers |
|---|---------|----------------|
| 4 | [App Entry & Navigation](04-app-entry-and-navigation.md) | `main.dart`, `app.dart`, `MaterialApp`, the route table, and the theme |
| 5 | [Authentication](05-authentication.md) | Login, Register, the dormant auth gate, and the Firebase Auth flow |
| 6 | [Blood Request & Donation](06-blood-request-and-donation.md) | The two core feature screens and the donor-registration write path |
| 7 | [Profile & Donation History](07-profile-and-donation-history.md) | Reading/updating the `User` document, profile pictures, and history |
| 8 | [Informational Screens](08-informational-screens.md) | Home, Blood Banks, Verified Hospitals, Emergency Contacts, FAQ, About Us |
| 9 | [Reusable Widgets & Data Models](09-widgets-and-models.md) | `MyTextField`, `MyCustomButtom`, `MenuItemCard`, `DonationHistory` |

### Part III — Data, Integrations & Configuration
| # | Chapter | What it covers |
|---|---------|----------------|
| 10 | [Data & Storage](10-data-and-storage.md) | Firestore collections, the ER diagram, and the two-identity-model problem |
| 11 | [Notifications (FCM)](11-notifications.md) | The Firebase Cloud Messaging pipeline and where it stops today |
| 12 | [Configuration Reference](12-configuration-reference.md) | Every config file and option: pubspec, Firebase options, Android manifest, Gradle |

### Part IV — Operations & Practice
| # | Chapter | What it covers |
|---|---------|----------------|
| 13 | [Testing](13-testing.md) | What tests exist, how to run them, and current coverage |
| 14 | [Deployment](14-deployment.md) | Building and shipping to Android, iOS, web, and desktop |
| 15 | [Troubleshooting / FAQ](15-troubleshooting.md) | Common problems and how to resolve them |
| 16 | [Security Considerations](16-security.md) | Auth flow, secrets, Firestore rules, and sensitive areas |

### Part V — Reference
| # | Chapter | What it covers |
|---|---------|----------------|
| 17 | [Glossary](17-glossary.md) | Project-specific and Flutter/Firebase terms |
| 18 | [Appendix](18-appendix.md) | Full file tree, dependency reference, CLI cheat sheet, and changelog |

---

## At a glance

| Property | Value |
|----------|-------|
| App name | EsperFlow |
| Type | Cross-platform mobile app (Flutter) |
| Primary target | Android |
| Language | Dart (SDK `^3.10.0`) |
| Backend | Firebase (Auth, Cloud Firestore, Cloud Messaging) |
| Dedicated server | None — the `backend/` folder is empty |
| Firebase project ID | `esperflow-1b828` |
| App version | `1.0.0+1` |
| Source root | [`frontend/`](../frontend/) |

> ⚠️ **Maturity:** EsperFlow is an **early-stage / student-project-grade** app. The UI for most features is built, but several flows are not yet wired to persistence, and the login/registration path is not reachable from the running app. The relevant chapters explain each gap precisely so you know what to trust and what to finish.
