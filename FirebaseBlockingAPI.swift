import Foundation

#if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
import FirebaseAuth
import FirebaseFirestore

final class FirebaseBlockingAPI: BlockingAPI {
    private let db = Firestore.firestore()
    private func userRef(_ uid: String) -> DocumentReference { db.collection("users").document(uid) }
    private func appsRef(_ uid: String) -> CollectionReference { userRef(uid).collection("apps") }
    private func sitesRef(_ uid: String) -> CollectionReference { userRef(uid).collection("websites") }

    func fetch(for userID: String) async throws -> BlockingSnapshot {
        let appsSnap = try await appsRef(userID).getDocuments()
        let sitesSnap = try await sitesRef(userID).getDocuments()
        let apps: [BlockedApp] = appsSnap.documents.compactMap { doc in
            guard let bundleId = doc.get("bundleIdentifier") as? String,
                  let name = doc.get("displayName") as? String,
                  let uuidString = doc.get("id") as? String,
                  let uuid = UUID(uuidString: uuidString) else { return nil }
            return BlockedApp(id: uuid, bundleIdentifier: bundleId, displayName: name)
        }
        let sites: [BlockedWebsite] = sitesSnap.documents.compactMap { doc in
            guard let domain = doc.get("domain") as? String,
                  let name = doc.get("displayName") as? String,
                  let uuidString = doc.get("id") as? String,
                  let uuid = UUID(uuidString: uuidString) else { return nil }
            return BlockedWebsite(id: uuid, domain: domain, displayName: name)
        }
        return BlockingSnapshot(apps: apps, websites: sites, updatedAt: Date())
    }

    func add(app: BlockedApp, for userID: String) async throws -> BlockingSnapshot {
        let doc = appsRef(userID).document(app.id.uuidString)
        try await doc.setData([
            "id": app.id.uuidString,
            "bundleIdentifier": app.bundleIdentifier,
            "displayName": app.displayName,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        return try await fetch(for: userID)
    }

    func removeApp(id: UUID, for userID: String) async throws -> BlockingSnapshot {
        try await appsRef(userID).document(id.uuidString).delete()
        return try await fetch(for: userID)
    }

    func add(website: BlockedWebsite, for userID: String) async throws -> BlockingSnapshot {
        let doc = sitesRef(userID).document(website.id.uuidString)
        try await doc.setData([
            "id": website.id.uuidString,
            "domain": website.domain,
            "displayName": website.displayName,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
        return try await fetch(for: userID)
    }

    func removeWebsite(id: UUID, for userID: String) async throws -> BlockingSnapshot {
        try await sitesRef(userID).document(id.uuidString).delete()
        return try await fetch(for: userID)
    }
}

#else
// Placeholder so project compiles without Firebase packages. Swap in FirebaseBlockingAPI once Firebase SDKs are added.
final class FirebaseBlockingAPI: BlockingAPIStub {}
#endif
