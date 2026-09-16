import DesignKit
import Foundation

public struct TanyaAIMessage: Equatable {
    /// Bounds both restored history and messages retained during a live chat.
    public static let historyLimit = 100

    public enum Role: Equatable {
        case user
        case assistant
        case system
    }

    public let identifier: String
    public let role: Role
    public var content: TanyaAIMessageContent

    public init(
        identifier: String,
        role: Role,
        content: TanyaAIMessageContent
    ) {
        self.identifier = identifier
        self.role = role
        self.content = content
    }
}
