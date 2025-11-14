import Foundation

public struct BlockedApp: Identifiable, Equatable, Codable {
    public let id: UUID
    public var bundleIdentifier: String
    public var displayName: String
    
    public init(id: UUID = UUID(), bundleIdentifier: String, displayName: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
    }
}

public struct BlockedWebsite: Identifiable, Equatable, Codable {
    public let id: UUID
    public var domain: String
    public var displayName: String
    
    public init(id: UUID = UUID(), domain: String, displayName: String) {
        self.id = id
        self.domain = domain
        self.displayName = displayName
    }
}
