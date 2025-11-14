import Foundation

public enum BlockType: String, Codable, CaseIterable, Identifiable {
    case app, domain, keyword

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .app: return "App"
        case .domain: return "Domain"
        case .keyword: return "Keyword"
        }
    }
}

public struct BlockItem: Identifiable, Codable, Equatable {
    public let id: String
    public var type: BlockType
    public var value: String
    public var notes: String?
    public var isActive: Bool
    public var createdAt: Date

    public init(id: String = UUID().uuidString, type: BlockType, value: String, notes: String? = nil, isActive: Bool = true, createdAt: Date = .now) {
        self.id = id
        self.type = type
        self.value = value
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

public struct BlockItemInput: Codable, Equatable {
    public var type: BlockType
    public var value: String
    public var notes: String?

    public init(type: BlockType, value: String, notes: String? = nil) {
        self.type = type
        self.value = value
        self.notes = notes
    }
}
