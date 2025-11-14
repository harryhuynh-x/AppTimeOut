import Foundation

public protocol BlocksService {
    func fetchBlocks() async throws -> [BlockItem]
    func addBlock(_ input: BlockItemInput) async throws -> BlockItem
    func removeBlock(id: String) async throws
    func toggleBlock(id: String, active: Bool) async throws -> BlockItem
}

public final class BlocksAPIClient: BlocksService {
    private var storage: [BlockItem] = [
        BlockItem(type: .domain, value: "example.com"),
        BlockItem(type: .app, value: "TikTok"),
        BlockItem(type: .keyword, value: "spoilers", isActive: false)
    ]
    
    public init() {}
    
    public func fetchBlocks() async throws -> [BlockItem] {
        try await Task.sleep(nanoseconds: 150_000_000)
        return storage.sorted { $0.createdAt < $1.createdAt }
    }
    
    public func addBlock(_ input: BlockItemInput) async throws -> BlockItem {
        try await Task.sleep(nanoseconds: 150_000_000)
        let item = BlockItem(type: input.type, value: input.value, notes: input.notes)
        storage.append(item)
        return item
    }
    
    public func removeBlock(id: String) async throws {
        try await Task.sleep(nanoseconds: 120_000_000)
        storage.removeAll { $0.id == id }
    }
    
    public func toggleBlock(id: String, active: Bool) async throws -> BlockItem {
        try await Task.sleep(nanoseconds: 120_000_000)
        guard let idx = storage.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "Blocks", code: 404)
        }
        storage[idx].isActive = active
        return storage[idx]
    }
}
