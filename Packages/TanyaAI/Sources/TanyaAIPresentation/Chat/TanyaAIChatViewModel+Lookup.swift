import Foundation
import TanyaAIDomain

/// Reading the conversation, and the values it is built from.
///
/// Split out so the ViewModel proper holds only what changes state.
extension TanyaAIChatViewModel {
    func message(identifier: String) -> TanyaAIMessageItemViewModel? {
        messages.first { $0.id == identifier }
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

    func makeSuggestion(
        _ payload: TanyaAISuggestionPayload
    ) -> TanyaAISuggestion {
        TanyaAISuggestion(
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

    static func makeWelcomeMessage() -> TanyaAIMessageItemViewModel {
        let message = TanyaAIMessage(
            identifier: "sandbox-welcome",
            role: .assistant,
            content: .text(
                "[bold]Welcome to the sanitized Tanya AI "
                    + "sandbox.[/bold] "
                    + "Ask for a sample portfolio to start the demo."
            )
        )
        return TanyaAIMessageItemViewModel(message: message)
    }
}
