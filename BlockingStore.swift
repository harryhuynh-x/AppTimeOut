import Foundation

// Models used by BlockingView

struct BlockedApp: Identifiable, Equatable, Codable {
    let id: UUID
    var bundleIdentifier: String
    var displayName: String

    init(id: UUID = UUID(), bundleIdentifier: String, displayName: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
    }
}

struct BlockedWebsite: Identifiable, Equatable, Codable {
    let id: UUID
    var domain: String
    var displayName: String

    init(id: UUID = UUID(), domain: String, displayName: String) {
        self.id = id
        self.domain = domain
        self.displayName = displayName
    }
}

struct BlockingSnapshot: Codable, Equatable {
    var apps: [BlockedApp]
    var websites: [BlockedWebsite]
    var updatedAt: Date
}

protocol BlockingStore {
    func load(for userID: String?) async throws -> BlockingSnapshot
    func save(_ snapshot: BlockingSnapshot, for userID: String?) async throws
}

protocol BlockingAPI {
    func fetch(for userID: String) async throws -> BlockingSnapshot
    func add(app: BlockedApp, for userID: String) async throws -> BlockingSnapshot
    func removeApp(id: UUID, for userID: String) async throws -> BlockingSnapshot
    func add(website: BlockedWebsite, for userID: String) async throws -> BlockingSnapshot
    func removeWebsite(id: UUID, for userID: String) async throws -> BlockingSnapshot
}

final class BlockingLocalStore: BlockingStore {
    private let fileManager = FileManager.default

    private func url(for userID: String?) throws -> URL {
        let base = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let name = userID.map { "blocking_\($0).json" } ?? "blocking_anon.json"
        return base.appendingPathComponent(name)
    }

    func load(for userID: String?) async throws -> BlockingSnapshot {
        let url = try url(for: userID)
        if !fileManager.fileExists(atPath: url.path) {
            return BlockingSnapshot(apps: [], websites: [], updatedAt: .distantPast)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(BlockingSnapshot.self, from: data)
    }

    func save(_ snapshot: BlockingSnapshot, for userID: String?) async throws {
        let url = try url(for: userID)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: url, options: .atomic)
    }
}

final class BlockingAPIStub: BlockingAPI {
    private var server: [String: BlockingSnapshot] = [:]

    func fetch(for userID: String) async throws -> BlockingSnapshot {
        try await Task.sleep(nanoseconds: 150_000_000)
        return server[userID] ?? BlockingSnapshot(apps: [], websites: [], updatedAt: .now)
    }

    func add(app: BlockedApp, for userID: String) async throws -> BlockingSnapshot {
        try await Task.sleep(nanoseconds: 100_000_000)
        var snap = server[userID] ?? BlockingSnapshot(apps: [], websites: [], updatedAt: .distantPast)
        if !snap.apps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            snap.apps.append(app)
        }
        snap.updatedAt = .now
        server[userID] = snap
        return snap
    }

    func removeApp(id: UUID, for userID: String) async throws -> BlockingSnapshot {
        try await Task.sleep(nanoseconds: 100_000_000)
        var snap = server[userID] ?? BlockingSnapshot(apps: [], websites: [], updatedAt: .distantPast)
        snap.apps.removeAll { $0.id == id }
        snap.updatedAt = .now
        server[userID] = snap
        return snap
    }

    func add(website: BlockedWebsite, for userID: String) async throws -> BlockingSnapshot {
        try await Task.sleep(nanoseconds: 100_000_000)
        var snap = server[userID] ?? BlockingSnapshot(apps: [], websites: [], updatedAt: .distantPast)
        if !snap.websites.contains(where: { $0.domain.caseInsensitiveCompare(website.domain) == .orderedSame }) {
            snap.websites.append(website)
        }
        snap.updatedAt = .now
        server[userID] = snap
        return snap
    }

    func removeWebsite(id: UUID, for userID: String) async throws -> BlockingSnapshot {
        try await Task.sleep(nanoseconds: 100_000_000)
        var snap = server[userID] ?? BlockingSnapshot(apps: [], websites: [], updatedAt: .distantPast)
        snap.websites.removeAll { $0.id == id }
        snap.updatedAt = .now
        server[userID] = snap
        return snap
    }
}
