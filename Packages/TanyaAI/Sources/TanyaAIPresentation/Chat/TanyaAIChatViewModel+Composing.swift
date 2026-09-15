import Foundation
import TanyaAIDomain

/// Turning what arrives into bubbles.
///
/// Split from the ViewModel proper so that file holds the conversation's
/// state and this one holds the rules for adding to it - chiefly that
/// nothing may overwrite a confirmation the customer has already settled.
extension TanyaAIChatViewModel {
    func appendUserMessage(_ text: String) {
        let message = TanyaAIMessage(
            identifier: UUID().uuidString,
            role: .user,
            content: .text(text)
        )
        appendMessage(TanyaAIMessageItemViewModel(message: message))
    }

    func appendAssistantPlaceholder(identifier: String) {
        let target = resolvedIdentifier(for: identifier)
        if let existing = message(identifier: target),
           isSettledApproval(existing.content) == false {
            return
        }
        appendContent(identifier: identifier, content: .text(""))
    }

    func appendTextDeltaNow(identifier: String, text: String) {
        // Text may not overwrite a settled confirmation either: routing
        // through `appendContent` gives the delta a fresh bubble.
        let target = resolvedIdentifier(for: identifier)
        guard let message = message(identifier: target),
              isSettledApproval(message.content) == false else {
            appendContent(identifier: identifier, content: .text(text))
            return
        }
        let existingText: String
        if case .text(let value) = message.content {
            existingText = value
        } else {
            existingText = ""
        }
        message.update(content: .text(existingText + text))
    }
}
