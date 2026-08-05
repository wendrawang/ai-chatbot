import Combine
import TanyaAIDomain

public final class TanyaAIMessageItemViewModel:
    ObservableObject,
    Identifiable {

    public let id: String
    public let role: TanyaAIMessage.Role

    @Published
    public private(set) var content: TanyaAIMessageContent

    public init(message: TanyaAIMessage) {
        id = message.id
        role = message.role
        content = message.content
    }

    public func update(content: TanyaAIMessageContent) {
        self.content = content
    }
}
