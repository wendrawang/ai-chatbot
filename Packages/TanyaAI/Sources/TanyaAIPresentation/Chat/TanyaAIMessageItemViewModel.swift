import Combine
import TanyaAIDomain

public final class TanyaAIMessageItemViewModel:
    ObservableObject {

    public let identifier: String
    public let role: TanyaAIMessage.Role

    @Published
    public private(set) var content: TanyaAIMessageContent
    private var isOptionsConsumed = false

    public init(message: TanyaAIMessage) {
        identifier = message.identifier
        role = message.role
        content = message.content
        switch message.content {
        case .answer(let payload): isOptionsConsumed = payload.isAnswered
        case .choices(let payload): isOptionsConsumed = payload.isSubmitted
        default: break
        }
    }

    public func update(content: TanyaAIMessageContent) {
        self.content = preservingSelection(in: content)
    }

    /// A replay of the same answer cannot bring back options already sent.
    func consumeOptions() {
        isOptionsConsumed = true
        update(content: content)
    }

    private func preservingSelection(in content: TanyaAIMessageContent) -> TanyaAIMessageContent {
        switch content {
        case .answer(var payload):
            isOptionsConsumed = isOptionsConsumed || payload.isAnswered
            payload.isAnswered = isOptionsConsumed
            return .answer(payload)
        case .choices(var payload):
            isOptionsConsumed = isOptionsConsumed || payload.isSubmitted
            payload.isSubmitted = isOptionsConsumed
            return .choices(payload)
        default:
            return content
        }
    }
}
