import Foundation
import TanyaAIDomain

extension TanyaAIChatViewModel {
    func appendUserMessage(_ text: String) -> TanyaAIMessageItemViewModel {
        let row = TanyaAIMessageItemViewModel(
            message: TanyaAIMessage(
                identifier: UUID().uuidString, role: .user, content: .text(text), delivery: .pending
            ))
        appendMessage(row)
        return row
    }

    func appendAssistantPlaceholder(identifier: String) {
        guard message(identifier: identifier) == nil else { return }
        appendContent(identifier: identifier, content: .text(""))
    }

    func appendTextDeltaNow(identifier: String, text: String) {
        guard let message = message(identifier: identifier) else {
            appendContent(identifier: identifier, content: .text(text))
            return
        }
        guard case .text(let previous) = message.content else { return }
        message.update(content: .text(previous + text))
    }
}
