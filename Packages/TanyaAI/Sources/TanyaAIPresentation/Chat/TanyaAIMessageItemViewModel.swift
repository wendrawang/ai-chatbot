import Combine
import TanyaAIDomain

@MainActor
public final class TanyaAIMessageItemViewModel:
    ObservableObject
{

    public let identifier: String
    public let role: TanyaAIMessage.Role

    @Published
    public private(set) var content: TanyaAIMessageContent
    @Published
    public private(set) var delivery: TanyaAIMessageDelivery?
    public private(set) var remoteIdentifier: String?
    private var isOptionsConsumed = false

    public init(message: TanyaAIMessage) {
        identifier = message.identifier
        role = message.role
        content = message.content
        delivery = message.delivery
        remoteIdentifier = message.remoteIdentifier ?? (message.role == .user ? nil : message.identifier)
        switch message.content {
        case .response(let payload): isOptionsConsumed = payload.isReadOnly
        default: break
        }
    }

    func setDelivery(_ delivery: TanyaAIMessageDelivery) { self.delivery = delivery }

    func setRemoteIdentifier(_ identifier: String) { remoteIdentifier = identifier }

    public func update(content: TanyaAIMessageContent) {
        let next = preservingSelection(in: content)
        if self.content != next { self.content = next }
    }

    /// A replay of the same answer cannot bring back options already sent.
    func consumeOptions() {
        guard !isOptionsConsumed else { return }
        isOptionsConsumed = true
        switch content {
        case .response: update(content: content)
        default: break
        }
    }

    private func preservingSelection(in content: TanyaAIMessageContent) -> TanyaAIMessageContent {
        switch content {
        case .response(let payload):
            isOptionsConsumed = isOptionsConsumed || payload.isReadOnly
            let previous: ResponsePayload?
            if case .response(let value) = self.content { previous = value } else { previous = nil }
            return .response(payload.preservingInteraction(from: previous, isReadOnly: isOptionsConsumed))
        default:
            return content
        }
    }
}
