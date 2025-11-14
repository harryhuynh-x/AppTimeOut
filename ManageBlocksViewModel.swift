import Foundation

@MainActor
public final class ManageBlocksViewModel: ObservableObject {
    @Published public private(set) var blocks: [BlockItem] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let service: BlocksService
    
    public init(service: BlocksService = BlocksAPIClient()) {
        self.service = service
    }
    
    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let items = try await service.fetchBlocks()
            blocks = items
        } catch {
            errorMessage = friendly(error)
        }
    }
    
    public func add(type: BlockType, value: String, notes: String? = nil) async {
        do {
            let input = BlockItemInput(type: type, value: value, notes: notes)
            let created = try await service.addBlock(input)
            blocks.append(created)
        } catch {
            errorMessage = friendly(error)
        }
    }
    
    public func remove(_ item: BlockItem) async {
        do {
            try await service.removeBlock(id: item.id)
            blocks.removeAll { $0.id == item.id }
        } catch {
            errorMessage = friendly(error)
        }
    }
    
    public func toggle(_ item: BlockItem, active: Bool) async {
        do {
            let updated = try await service.toggleBlock(id: item.id, active: active)
            if let idx = blocks.firstIndex(where: { $0.id == updated.id }) {
                blocks[idx] = updated
            }
        } catch {
            errorMessage = friendly(error)
        }
    }
    
    private func friendly(_ error: Error) -> String {
        (error as NSError).localizedDescription
    }
}
