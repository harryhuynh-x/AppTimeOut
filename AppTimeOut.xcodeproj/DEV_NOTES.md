# Project Dev Notes
# Updated Date: 11/13/2025
# Last Edited In-Project: 11/14/2025
## Quick Context
- SwiftUI iOS app with Dashboard, Manage Blocks (BlockingView), Partner features, and Profile/Subscriptions.
- Subscriptions via StoreKit 2 (`SubscriptionManager`).
- Firebase integrated via SPM; `FirebaseApp.configure()` is called at launch.

- Primary goal: iPhone/iPad app that blocks other apps and websites (e.g., social media) with self-lock and partner-assisted unlock. (11/14/2025)

## Features & Goals (Authoritative)
- Block apps by bundle ID and categories (e.g., Social Networking) (11/14/2025)
- Block websites/domains across the device using Screen Time web restrictions (11/14/2025)
- Self-lock: user can lock selected apps/sites for a duration or until a scheduled time (11/14/2025)
- Partner unlock: generate one-time unlock codes; partner approves via code entry (email/SMS workflow) (11/14/2025)
- Auditability: record lock/unlock events and who approved (11/14/2025)
- Premium gating: longer lock durations, categories, partner features via StoreKit 2 (11/14/2025)
- Sync: local JSON cache + Firebase Firestore as backend of truth when signed in (11/14/2025)

## Manage Blocks (Current Architecture)
- Screen: `BlockingView` (BlockView.swift) — lists Apps and Websites; add via app picker / URL entry; delete via swipe.
- Hybrid persistence/sync:
  - Local cache: `BlockingLocalStore` (JSON snapshot per user) via `BlockingStore` protocol.
  - Cloud backend: `FirebaseBlockingAPI` (Firestore) implementing `BlockingAPI`.
  - Coordinator: `BlockingSyncCoordinator` (ObservableObject) orchestrates load/add/remove/toggle, optimistic updates, local save, and server sync.
- User identity for sync:
  - `BlockingView` initializes the coordinator with `userIDProvider: { Auth.auth().currentUser?.uid }` when FirebaseAuth is available.
  - When signed in, Firestore path: `/users/{uid}/apps` and `/users/{uid}/websites`.
- Models:
  - `BlockedApp(id: UUID = UUID(), bundleIdentifier: String, displayName: String)`
  - `BlockedWebsite(id: UUID = UUID(), domain: String, displayName: String)`
  - Both are `Identifiable`, `Equatable`, `Codable` and currently defined in `BlockView.swift`.

## Enforcement Approach (iOS/iPadOS)
On iOS/iPadOS, enforcement uses Screen Time (Family Controls) as the system-sanctioned mechanism. Network Extension is optional and may be deferred. (11/14/2025)

### Primary: Family Controls / Screen Time
- Frameworks: FamilyControls, ManagedSettings, DeviceActivity (11/14/2025)
- Entitlement: Family Controls (request via Apple Developer account) (11/14/2025)
- Capabilities: shield apps by bundle ID, categories, and restrict websites (11/14/2025)

### Optional: Network Extension (Advanced)
- DNS Proxy or Packet Tunnel for systemwide domain filtering (11/14/2025)
- Entitlement: com.apple.developer.networking.networkextension (specific provider types) (11/14/2025)
- Stricter App Review; consider later phase (11/14/2025)

## Lock & Unlock Flows

### Self-Lock
- User selects apps/sites from BlockingView (11/14/2025)
- Creates a Lock Session (start/end or duration) and applies shields via ManagedSettings (11/14/2025)
- Persists session locally and in Firestore; schedules DeviceActivity as needed (11/14/2025)

### Partner Unlock
- Generate one-time code (short-lived, single-use) (11/14/2025)
- Share via Messages/Email (MVP) or server-sent SMS (future) (11/14/2025)
- Partner submits code; backend (Cloud Function) verifies and updates session state (11/14/2025)
- App observes session state and removes or pauses shields upon approval (11/14/2025)

## Firebase Setup (Done)
- Firebase project + iOS app created; `GoogleService-Info.plist` added to target.
- SPM packages added: `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`.
- App initialization: `FirebaseApp.configure()` in `AppTimeOutApp`.

## Files of Interest
- `BlockView.swift`: UI + models + coordinator wiring (uses Firebase UID when available).
- `BlockingStore.swift`: `BlockingSnapshot`, `BlockingStore`, `BlockingAPI`, `BlockingLocalStore`, `BlockingAPIStub`.
- `BlockingSyncCoordinator.swift`: Loads from local, then server; optimistic updates; saves back to local.
- `FirebaseBlockingAPI.swift`: Firestore CRUD under `/users/{uid}/apps` and `/users/{uid}/websites` (conditional imports).
- `AppTimeOutApp.swift`: App entry; calls `FirebaseApp.configure()`.
- `LockDashboardView.swift`: Entry to `BlockingView` via toolbar menu.
- `SubscriptionManager.swift`: StoreKit 2 entitlements.
- `LockSession` (to be added): model for active/pending locks with timings and approval state (11/14/2025)
- `ShieldingService` (to be added): applies/removes ManagedSettings shields from current snapshot (11/14/2025)

## Cleanups Done
- Removed/neutralized redundant files: `ManageBlocksScreen.swift`, `ManageBlocksViewModel.swift`, `ManageBlocksModels.swift`, `BlocksService.swift`.
- Note: `BlockingModels.swift` is intentionally empty after revert; safe to delete.

## What Works Now
- Manage Blocks persists locally and syncs to Firestore when signed in.
- UI behaves as before (add, delete, free vs premium messaging).
- Firebase initializes at launch.

## Next Steps (Recommended Order)
1) Request Family Controls entitlement and add frameworks (FamilyControls, ManagedSettings, DeviceActivity). (11/14/2025)
2) Implement authorization UI and a minimal ShieldingService to apply/remove app and website shields from current snapshot. (11/14/2025)
3) Design and persist `LockSession` in Firestore (`/users/{uid}/lockSessions/{sessionId}`) and locally; wire Self-Lock start/stop. (11/14/2025)
4) Implement Partner Unlock MVP: generate one-time codes, share via Messages/Email, verify in-app (temporary), then migrate to Cloud Function verification. (11/14/2025)
5) Implement Sign-In (Apple or Email/Password) and, post-login, call `await sync.load()` to adopt server snapshot. (11/14/2025)
6) Write Firestore Security Rules for users to access only their own docs (users/{uid}/apps, websites, lockSessions). (11/14/2025)
7) Error UX + Retry for sync and code verification; non-blocking banners and backoff retries. (11/14/2025)
8) Premium gating centralization for limits/durations and partner features via SubscriptionManager. (11/14/2025)
9) Optional: Evaluate Network Extension (DNS Proxy/VPN) if Screen Time web restrictions are insufficient. (11/14/2025)

## Paste This in Future Chats
"We are building an iPhone/iPad app that blocks apps and websites using Family Controls (Screen Time). Users can self-lock or use a partner unlock code workflow. Data syncs via local JSON + Firebase Firestore. `BlockingView` uses `BlockingSyncCoordinator` with `userIDProvider: { Auth.auth().currentUser?.uid }`. Next steps: request Family Controls entitlement, add ShieldingService + LockSession, implement sign-in and Firestore rules, add error handling/retry, and centralize premium gating." (11/14/2025)
