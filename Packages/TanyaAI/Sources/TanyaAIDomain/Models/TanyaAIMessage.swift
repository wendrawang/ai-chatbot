import Foundation

public struct TanyaAIMessage: Identifiable, Equatable {
    public enum Role: Equatable {
        case user
        case assistant
        case system
    }

    public let id: String
    public let role: Role
    public var content: TanyaAIMessageContent

    public init(
        identifier: String,
        role: Role,
        content: TanyaAIMessageContent
    ) {
        id = identifier
        self.role = role
        self.content = content
    }
}
