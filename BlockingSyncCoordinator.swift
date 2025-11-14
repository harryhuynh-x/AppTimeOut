import Foundation
import Combine

@MainActor
final class BlockingSyncCoordinator: ObservableObject {
    @Published private(set) var apps: [BlockedApp] = []
    @Published private(set) var websites: [BlockedWebsite] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let local: BlockingStore
    private let api: BlockingAPI
    private let userIDProvider: () -> String?

    init(
        local: BlockingStore = BlockingLocalStore(),
        api: BlockingAPI? = nil,
        userIDProvider: @escaping () -> String? = { nil }
    ) {
        self.local = local
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        self.api = api ?? FirebaseBlockingAPI()
        #else
        self.api = api ?? BlockingAPIStub()
        #endif
        self.userIDProvider = userIDProvider
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        let uid = userIDProvider()
        do {
            let localSnap = try await local.load(for: uid)
            apps = localSnap.apps
            websites = localSnap.websites

            if let uid = uid {
                let serverSnap = try await api.fetch(for: uid)
                // Replace local with server for simplicity (policy: server authoritative)
                apps = serverSnap.apps
                websites = serverSnap.websites
                try await local.save(serverSnap, for: uid)
            }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func addApp(_ app: BlockedApp) async {
        let uid = userIDProvider()
        apps.append(app)
        let newSnap = BlockingSnapshot(apps: apps, websites: websites, updatedAt: Date())
        try? await local.save(newSnap, for: uid)

        if let uid = uid {
            do {
                let serverSnap = try await api.add(app: app, for: uid)
                apps = serverSnap.apps
                websites = serverSnap.websites
                try? await local.save(serverSnap, for: uid)
            } catch {
                errorMessage = (error as NSError).localizedDescription
            }
        }
    }

    func removeApp(id: UUID) async {
        let uid = userIDProvider()
        apps.removeAll { $0.id == id }
        let newSnap = BlockingSnapshot(apps: apps, websites: websites, updatedAt: Date())
        try? await local.save(newSnap, for: uid)

        if let uid = uid {
            do {
                let serverSnap = try await api.removeApp(id: id, for: uid)
                apps = serverSnap.apps
                websites = serverSnap.websites
                try? await local.save(serverSnap, for: uid)
            } catch {
                errorMessage = (error as NSError).localizedDescription
            }
        }
    }

    func addWebsite(_ site: BlockedWebsite) async {
        let uid = userIDProvider()
        websites.append(site)
        let newSnap = BlockingSnapshot(apps: apps, websites: websites, updatedAt: Date())
        try? await local.save(newSnap, for: uid)

        if let uid = uid {
            do {
                let serverSnap = try await api.add(website: site, for: uid)
                apps = serverSnap.apps
                websites = serverSnap.websites
                try? await local.save(serverSnap, for: uid)
            } catch {
                errorMessage = (error as NSError).localizedDescription
            }
        }
    }

    func removeWebsite(id: UUID) async {
        let uid = userIDProvider()
        websites.removeAll { $0.id == id }
        let newSnap = BlockingSnapshot(apps: apps, websites: websites, updatedAt: Date())
        try? await local.save(newSnap, for: uid)

        if let uid = uid {
            do {
                let serverSnap = try await api.removeWebsite(id: id, for: uid)
                apps = serverSnap.apps
                websites = serverSnap.websites
                try? await local.save(serverSnap, for: uid)
            } catch {
                errorMessage = (error as NSError).localizedDescription
            }
        }
    }
}
