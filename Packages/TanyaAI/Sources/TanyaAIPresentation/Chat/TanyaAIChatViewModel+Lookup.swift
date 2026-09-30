import DesignKit
import Foundation
import TanyaAIDomain

/// Reading the conversation, and the values it is built from.
///
/// Split out so the ViewModel proper holds only what changes state.
extension TanyaAIChatViewModel {
    func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messages.first { $0.identifier == identifier }
    }

    /// The newest bubble carrying this approval identifier.
    ///
    /// A settled confirmation stays on screen, so a repeated approval creates
    /// a second bubble; state updates belong to the newest one.
    func approvalMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messages.last { message in
            guard case .approval(let payload) = message.content else {
                return false
            }
            return payload.approvalIdentifier == identifier
        }
    }

    /// The newest bubble carrying this choices identifier, for the same
    /// reason as `approvalMessage`: a repeated question makes a second card,
    /// and taps belong to the one in front of the customer.
    func choicesMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messages.last { message in
            guard case .choices(let payload) = message.content else {
                return false
            }
            return payload.identifier == identifier
        }
    }

    func liveAgentMessage(
        identifier: String
    ) -> TanyaAIMessageItemViewModel? {
        messages.last { message in
            guard case .liveAgent(let payload) = message.content else {
                return false
            }
            return payload.identifier == identifier
        }
    }

    func makeSuggestion(
        _ payload: TanyaAISuggestionPayload
    ) -> Suggestion {
        Suggestion(
            identifier: payload.identifier,
            title: payload.title,
            prompt: payload.prompt
        )
    }

    /// Hops to the main queue only when it has to. A session may deliver on
    /// any queue, and an extra hop per event would be visible while streaming.
    func performOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
