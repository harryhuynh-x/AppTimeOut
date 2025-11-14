# Project Dev Notes

## Quick Context
- SwiftUI iOS app with Dashboard, Manage Blocks (BlockingView), Partner features, and Profile/Subscriptions.
- Subscriptions via StoreKit 2 (`SubscriptionManager`).
- Firebase integrated via SPM; `FirebaseApp.configure()` is called at launch.

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

## Cleanups Done
- Removed/neutralized redundant files: `ManageBlocksScreen.swift`, `ManageBlocksViewModel.swift`, `ManageBlocksModels.swift`, `BlocksService.swift`.
- Note: `BlockingModels.swift` is intentionally empty after revert; safe to delete.

## What Works Now
- Manage Blocks persists locally and syncs to Firestore when signed in.
- UI behaves as before (add, delete, free vs premium messaging).
- Firebase initializes at launch.

## Next Steps (Recommended Order)
1) Sign-in flow (Firebase Auth)
   - Implement Apple Sign In or Email/Password to set `Auth.auth().currentUser?.uid`.
   - After sign-in, call `await sync.load()` to fetch and replace with server snapshot.
2) Firestore Security Rules
   - Restrict access so users can read/write only their own docs:
     - `/users/{uid}/apps/{doc}`
     - `/users/{uid}/websites/{doc}`
3) Error UX + Retry
   - Show non-blocking banner/inline error for sync failures; consider automatic retry with backoff.
4) Premium Gating Consistency
   - Centralize free vs premium limits (e.g., helper/Entitlements) and use across BlockingView and other premium features.
5) Partner/Guardian Persistence (Optional for MVP)
   - Persist partner contact/method; wire partner-protected actions.
6) Optional: Real App Store search; tests for domain normalization and limits.

## Paste This in Future Chats
- “We are building a hybrid Manage Blocks system (local JSON + Firebase Firestore). `BlockingView` uses `BlockingSyncCoordinator` with `userIDProvider: { Auth.auth().currentUser?.uid }`. Firebase is initialized. Next steps: add Firebase Auth sign-in (Apple or Email), apply Firestore Security Rules, add error handling/retry, and centralize premium gating. Models (`BlockedApp`/`BlockedWebsite`) are defined in `BlockView.swift`.”
