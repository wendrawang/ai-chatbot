import Combine
import TanyaAIDomain

public final class TanyaAIMessageItemViewModel:
    ObservableObject {

    public let identifier: String
    public let role: TanyaAIMessage.Role

    @Published
    public private(set) var content: TanyaAIMessageContent

    public init(message: TanyaAIMessage) {
        identifier = message.identifier
        role = message.role
        content = message.content
    }

    public func update(content: TanyaAIMessageContent) {
        self.content = content
    }
}
